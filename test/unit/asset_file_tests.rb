require 'assert'
require 'dassets/asset_file'

class Dassets::AssetFile

  class BaseTests < Assert::Context
    desc "Dassets::AssetFile"
    setup do
      @file_path = File.join(Dassets.config.files_path, 'file1.txt')
      @asset_file = Dassets::AssetFile.new(@file_path, "#{Dassets.config.files_path}/")
    end
    subject{ @asset_file }

    should have_imeths :path, :md5

    should "track it's path relative to its given relative path" do
      assert_equal 'file1.txt', subject.path
    end

    should "compute its md5 checksum" do
      assert_equal 'daa05c683a4913b268653f7a7e36a5b4', subject.md5
    end

  end

end
