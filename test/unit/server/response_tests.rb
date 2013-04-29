require 'assert'
require 'rack/utils'
require 'dassets/server/response'

class Dassets::Server::Response

  class BaseTests < Assert::Context
    desc "Dassets::Server::Response"
    setup do
      @resp = file_response(Dassets::AssetFile.new(''))
    end
    subject{ @resp }

    should have_readers :asset_file, :status, :headers, :body
    should have_imeths :to_rack

    should "handle not modified files" do
      af = Dassets['file1.txt']
      resp = file_response(af, 'HTTP_IF_MODIFIED_SINCE' => af.mtime)

      assert_equal 304, resp.status
      assert_equal [], resp.body
      assert_equal Rack::Utils::HeaderHash.new, resp.headers
      assert_equal [ 304, {}, [] ], resp.to_rack
    end

    should "handle found files" do
      af = Dassets['file1.txt']
      resp = file_response(af)
      exp_headers = {
        'Content-Type'   => 'text/plain',
        'Content-Length' => Rack::Utils.bytesize(af.content).to_s,
        'Last-Modified'  => af.mtime.to_s
      }

      assert_equal 200, resp.status
      assert_equal [ af.content ], resp.body
      assert_equal exp_headers, resp.headers
      assert_equal [ 200, exp_headers, [ af.content ] ], resp.to_rack
    end

    should "have an empty body for found files with a HEAD request" do
      af = Dassets['file1.txt']
      resp = file_response(af, 'REQUEST_METHOD' => 'HEAD')

      assert_equal 200, resp.status
      assert_equal [], resp.body
    end

    should "handle not found files" do
      af = Dassets['not-found-file.txt']
      resp = file_response(af)

      assert_equal 404, resp.status
      assert_equal ['Not Found'], resp.body
      assert_equal Rack::Utils::HeaderHash.new, resp.headers
      assert_equal [ 404, {}, ['Not Found'] ], resp.to_rack
    end

    protected

    def file_response(asset_file, env={})
      require 'dassets/server/response'
      Dassets::Server::Response.new(env, asset_file)
    end

  end

end
