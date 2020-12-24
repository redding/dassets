require "assert"
require "dassets/server/request"

require "dassets/asset_file"

class Dassets::Server::Request
  class UnitTests < Assert::Context
    desc "Dassets::Server::Request"
    subject { @req }

    setup do
      @path = "/file1-daa05c683a4913b268653f7a7e36a5b4.txt"
      @req = file_request("GET", @path)
    end

    should have_imeths :dassets_base_url
    should have_imeths :for_asset_file?, :asset_path, :asset_file

    should "know its attributes" do
      assert_that(subject.dassets_base_url).equals(Dassets.config.base_url.to_s)
      assert_that(subject.path_info).equals(@path)
      assert_that(subject.asset_path).equals("file1.txt")
      assert_that(subject.asset_file).equals(Dassets["file1.txt"])
    end

    should "know if it is for an asset file" do
      # find nested path with matching fingerprint
      req =
        file_request(
          "GET",
          "/nested/file3-d41d8cd98f00b204e9800998ecf8427e.txt"
        )
      assert_that(req.for_asset_file?).is_true

      # find not nested path with matching fingerprint
      req = file_request("HEAD", "/file1-daa05c683a4913b268653f7a7e36a5b4.txt")
      assert_that(req.for_asset_file?).is_true

      # find even if fingerprint is *not* matching - just need to have any fingerprint
      req = file_request("GET", "/file1-d41d8cd98f00b204e9800998ecf8427e.txt")
      assert_that(req.for_asset_file?).is_true

      # not find an invalid fingerprint
      req = file_request("GET", "/file1-abc123.txt")
      assert_that(req.for_asset_file?).is_false

      # not find a missing fingerprint
      req = file_request("HEAD", "/file1.txt")
      assert_that(req.for_asset_file?).is_false

      # not find an unknown file with a missing fingerprint
      req = file_request("GET", "/some-file.txt")
      assert_that(req.for_asset_file?).is_false

      # not find an unknown file with a valid fingerprint
      req =
        file_request("GET", "/some-file-daa05c683a4913b268653f7a7e36a5b4.txt")
      assert_that(req.for_asset_file?).is_false
    end

    should "return an empty path and file if request not for an asset file" do
      req = file_request("GET", "/some-file.txt")

      assert_that(req.asset_path).equals("")
      assert_that(req.asset_file).equals(Dassets::AssetFile.new(""))
    end

    private

    def file_request(method, path_info)
      Dassets::Server::Request.new({
        "REQUEST_METHOD" => method,
        "PATH_INFO"      => path_info
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
      assert_that(subject.dassets_base_url).equals(@new_base_url.to_s)
    end

    should "remove the configured base url from the path info" do
      assert_that(file_request("GET", @path).path_info).equals(@path)
      assert_that(file_request("GET", "#{@new_base_url}#{@path}").path_info)
        .equals(@path)
    end
  end
end
