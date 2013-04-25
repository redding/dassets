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
    should have_readers :path, :md5, :dirname, :extname, :basename
    should have_readers :output_path, :url, :href
    should have_imeth :content, :mtime, :size, :mime_type, :exists?, :==

    should "know its given path and md5" do
      assert_equal 'file1.txt', subject.path
      assert_equal 'abc123', subject.md5
    end

    should "know its dirname, extname, and basename" do
      assert_equal '.',     subject.dirname
      assert_equal '.txt',  subject.extname
      assert_equal 'file1', subject.basename
    end

    should "build it's output_path from the path" do
      assert_equal "#{Dassets.config.output_path}/file1.txt", subject.output_path

      nested = Dassets::AssetFile.new('nested/file1.txt', 'abc123')
      assert_equal "#{Dassets.config.output_path}/nested/file1.txt", nested.output_path
    end

    should "build it's url from the path and the md5" do
      assert_equal "file1-abc123.txt", subject.url

      nested = Dassets::AssetFile.new('nested/file1.txt', 'abc123')
      assert_equal "nested/file1-abc123.txt", nested.url
    end

    should "build it's href from the url" do
      assert_equal "/file1-abc123.txt", subject.href

      nested = Dassets::AssetFile.new('nested/file1.txt', 'abc123')
      assert_equal "/nested/file1-abc123.txt", nested.href
    end

    should "be created from absolute file paths and have md5 computed" do
      abs_file_path = File.join(Dassets.config.output_path, 'file1.txt')
      exp_md5 = 'daa05c683a4913b268653f7a7e36a5b4'
      file = Dassets::AssetFile.from_abs_path(abs_file_path)

      assert_equal 'file1.txt', file.path
      assert_equal exp_md5, file.md5
    end

    should "know it's content, mtime, size, mime_type, and if it exists" do
      assert_equal "file1.txt\n", subject.content
      assert_equal File.mtime(subject.output_path).httpdate, subject.mtime
      assert_equal File.size?(subject.output_path), subject.size
      assert_equal "text/plain", subject.mime_type
      assert subject.exists?

      null_file = Dassets::AssetFile.new('', '')
      assert_nil null_file.content
      assert_nil null_file.mtime
      assert_nil null_file.size
      assert_nil null_file.mime_type
      assert_not null_file.exists?
    end

  end

end
