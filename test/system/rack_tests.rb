require 'assert'
require 'assert-rack-test'
require 'fileutils'
require 'test/support/app'
require 'dassets/server'

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

  end

  class DigestTests < SuccessTests
    setup do
      Dassets.config.file_store = TEST_SUPPORT_PATH.join('public').to_s
      @url = 'file1-daa05c683a4913b268653f7a7e36a5b4.txt'
      @url_file = Dassets.config.file_store.store_path(@url)
      FileUtils.rm(@url_file)
    end
    teardown do
      Dassets.config.file_store = NullFileStore.new
    end

    should "digest the asset" do
      assert_not_file_exists @url_file

      resp = get "/#{@url}"
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
