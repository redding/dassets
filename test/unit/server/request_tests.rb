require 'assert'
require 'dassets/server/request'

require 'dassets'
require 'dassets/asset_file'

class Dassets::Server::Request

  class UnitTests < Assert::Context
    desc "Dassets::Server::Request"
    setup do
      @path = '/file1-daa05c683a4913b268653f7a7e36a5b4.txt'
      @req = file_request('GET', @path)
    end
    subject{ @req }

    should have_imeths :dassets_base_url
    should have_imeths :for_asset_file?, :asset_path, :asset_file

    should "know its base url" do
      assert_equal Dassets.config.base_url.to_s, subject.dassets_base_url
    end

    should "know its path info" do
      assert_equal @path, subject.path_info
    end

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

      # not find an invalid fingerprint
      req = file_request('GET', '/file1-abc123.txt')
      assert_not req.for_asset_file?

      # not find a missing fingerprint
      req = file_request('HEAD', '/file1.txt')
      assert_not req.for_asset_file?

      # not find an unknown file with a missing fingerprint
      req = file_request('GET', '/some-file.txt')
      assert_not req.for_asset_file?

      # complain with an unknown file with a valid fingerprint
      req = file_request('GET', '/some-file-daa05c683a4913b268653f7a7e36a5b4.txt')
      assert_raises(Dassets::AssetFileError){ req.for_asset_file? }
    end

    should "return an asset path and complain if request not for asset file" do
      req = file_request('GET', '/some-file.txt')

      assert_equal '', req.asset_path
      assert_raises(Dassets::AssetFileError){ req.asset_file }
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

  class BaseUrlTests < UnitTests
    desc "when a base url is configured"
    setup do
      @orig_base_url = Dassets.config.base_url
      @new_base_url  = Factory.url
      Dassets.config.base_url(@new_base_url)
    end
    teardown do
      Dassets.config.set_base_url(@orig_base_url)
    end

    should "have the same base url as is configured" do
      assert_equal @new_base_url.to_s, subject.dassets_base_url
    end

    should "remove the configured base url from the path info" do
      assert_equal @path, file_request('GET', @path).path_info
      assert_equal @path, file_request('GET', "#{@new_base_url}#{@path}").path_info
    end

  end

end
