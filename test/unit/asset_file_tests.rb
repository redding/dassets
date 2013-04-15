require 'assert'
require 'dassets/asset_file'

class Dassets::AssetFile

  class BaseTests < Assert::Context
    desc "Dassets::AssetFile"
    setup do
      @asset_file = Dassets::AssetFile.new('file1.txt', 'abc123')
    end
    subject{ @asset_file }

    should have_cmeths :from_abs_path
    should have_readers :path, :md5
    should have_imeth :cache_path

    should "know its given path and md5" do
      assert_equal 'file1.txt', subject.path
      assert_equal 'abc123', subject.md5
    end

    should "build it's cache_path from the path and the md5" do
      path = subject.path
      fingerprint = subject.md5

      dirname  = File.dirname(path)
      extname  = File.extname(path)
      basename = File.basename(path, extname)
      exp_path = File.join(dirname, "#{basename}-#{fingerprint}#{extname}")

      assert_equal exp_path, subject.cache_path
    end

    should "be created from absolute file paths and have md5 computed" do
      abs_file_path = File.join(Dassets.config.files_path, 'file1.txt')
      exp_md5 = 'daa05c683a4913b268653f7a7e36a5b4'
      file = Dassets::AssetFile.from_abs_path(abs_file_path)

      assert_equal 'file1.txt', file.path
      assert_equal exp_md5, file.md5
    end

  end

end
