require 'assert'
require 'dassets/asset_file'

class Dassets::AssetFile

  class BaseTests < Assert::Context
    desc "Dassets::AssetFile"
    setup do
      @file_path = File.join(Dassets.config.files_path, 'file1.txt')
      @asset_file = Dassets::AssetFile.new(@file_path)
    end
    subject{ @asset_file }

    should have_imeths :path, :md5

    should "know its path" do
      assert_equal @file_path, subject.path
    end

    should "compute its md5 checksum" do
      assert_equal 'daa05c683a4913b268653f7a7e36a5b4', subject.md5
    end

  end

end
