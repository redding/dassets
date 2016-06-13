require 'assert'
require 'dassets'

require 'assert-rack-test'
require 'fileutils'
require 'dassets/server'
require 'test/support/app'

module Dassets

  class RackTests < Assert::Context
    include Assert::Rack::Test

    desc "the middleware in a rack app"
    setup do
      app.use Dassets::Server
    end

    def app
      @app ||= SinatraApp
    end

  end

  class SuccessTests < RackTests
    desc "requesting an existing asset file"

    should "return a successful response" do
      resp = get '/file1-daa05c683a4913b268653f7a7e36a5b4.txt'
      assert_equal 200, resp.status
      assert_equal Dassets['file1.txt'].content, resp.body
    end

    should "return a successful response with no body on HEAD requests" do
      resp = head '/file2-9bbe1047cffbb590f59e0e5aeff46ae4.txt'
      assert_equal 200, resp.status
      assert_equal Dassets['file2.txt'].size.to_s, resp.headers['Content-Length']
      assert_empty resp.body
    end

    should "return a partial content response on valid partial content requests" do
      content = Dassets['file1.txt'].content
      size    = Factory.integer(content.length)

      # see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35
      env = { 'HTTP_RANGE' => "bytes=0-#{size}" }

      resp = get '/file1-daa05c683a4913b268653f7a7e36a5b4.txt', {}, env
      assert_equal 206, resp.status
      assert_equal content[0..size], resp.body
    end

    should "return a full response on no-range partial content requests" do
      # see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35
      env = { 'HTTP_RANGE' => 'bytes=' }

      resp = get '/file1-daa05c683a4913b268653f7a7e36a5b4.txt', {}, env
      assert_equal 200, resp.status
      assert_equal Dassets['file1.txt'].content, resp.body
    end

    should "return a full response on multiple-range partial content requests" do
      # see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35
      env = { 'HTTP_RANGE' => 'bytes=0-1,2-3' }

      resp = get '/file1-daa05c683a4913b268653f7a7e36a5b4.txt', {}, env
      assert_equal 200, resp.status
      assert_equal Dassets['file1.txt'].content, resp.body
    end

    should "return a full response on invalid-range partial content requests" do
      # see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35
      env = { 'HTTP_RANGE' => ['bytes=3-2', 'bytes=abc'].sample }

      resp = get '/file1-daa05c683a4913b268653f7a7e36a5b4.txt', {}, env
      assert_equal 200, resp.status
      assert_equal Dassets['file1.txt'].content, resp.body
    end

  end

  class DigestTests < SuccessTests
    setup do
      base_url = Factory.base_url
      Assert.stub(Dassets.config, :base_url){ base_url }
      Dassets.config.file_store TEST_SUPPORT_PATH.join('public').to_s
      @url = Dassets['file1.txt'].url
      @url_file = Dassets.config.file_store.store_path(@url)
    end
    teardown do
      FileUtils.rm(@url_file)
      Dassets.config.file_store FileStore::NullStore.new
    end

    should "digest the asset" do
      assert_not_file_exists @url_file

      resp = get @url
      assert_equal 200, resp.status
      assert_file_exists @url_file
    end

  end

  class NotModifiedTests < RackTests
    desc "requesting an existing asset file that has not been modified"
    setup do
      @resp = get('/file1-daa05c683a4913b268653f7a7e36a5b4.txt', {}, {
        'HTTP_IF_MODIFIED_SINCE' => Dassets['file1.txt'].mtime.to_s
      })
    end

    should "return a successful response" do
      assert_equal 304, @resp.status
      assert_empty @resp.body
    end

  end

  class NotFoundTests < RackTests
    desc "requesting an non-existing asset file"

    should "return a not found response" do
      resp = get '/file1-daa05c683a4913b268.txt'
      assert_equal 404, resp.status

      get '/file1-.txt'
      assert_equal 404, resp.status

      get '/file1.txt'
      assert_equal 404, resp.status

      get '/something-not-found'
      assert_equal 404, resp.status
    end

  end

end
