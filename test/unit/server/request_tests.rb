require 'assert'
require 'dassets/server/request'

class Dassets::Server::Request

  class BaseTests < Assert::Context
    desc "Dassets::Server::Request"
    setup do
      Dassets.init
      @req = file_request('GET', '/file1-daa05c683a4913b268653f7a7e36a5b4.txt')
    end
    teardown do
      Dassets.reset
    end
    subject{ @req }

    should have_imeths :for_asset_file?, :asset_path, :asset_file

    should "know its asset_path" do
      assert_equal 'file1.txt', subject.asset_path
    end

    should "know its asset_file" do
      assert_equal Dassets['file1.txt'], subject.asset_file
    end

    should "know if it is for an asset file" do
      # find nested path with matching fingerprint
      req = file_request('GET', '/nested/file3-d41d8cd98f00b204e9800998ecf8427e.txt')
      assert req.for_asset_file?

      # find not nested path with matching fingerprint
      req = file_request('HEAD', '/file1-daa05c683a4913b268653f7a7e36a5b4.txt')
      assert req.for_asset_file?

      # find even if fingerprint is *not* matching - just need to have any fingerprint
      req = file_request('GET', '/file1-d41d8cd98f00b204e9800998ecf8427e.txt')
      assert req.for_asset_file?

      # no find on invalid fingerprint
      req = file_request('GET', '/file1-daa05c683a4913b268653f7a7e36a.txt')
      assert_not req.for_asset_file?

      # no find on missing fingerprint
      req = file_request('HEAD', '/file1.txt')
      assert_not req.for_asset_file?

      # no find on unknown file
      req = file_request('GET', '/some-file.txt')
      assert_not req.for_asset_file?

      # no find on unknown file with an fingerprint
      req = file_request('GET', '/some-file-daa05c683a4913b268653f7a7e36a5b4.txt')
      assert_not req.for_asset_file?
    end

    should "return an asset path and an empty asset file if request not for asset file" do
      req = file_request('GET', '/some-file.txt')

      assert_equal '', req.asset_path
      assert_equal Dassets::AssetFile.new(''), req.asset_file
    end

    protected

    def file_request(method, path_info)
      require 'dassets/server/request'
      Dassets::Server::Request.new({
        'REQUEST_METHOD' => method,
        'PATH_INFO'      => path_info
      })
    end

  end

end
