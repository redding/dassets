require 'assert'
require 'fileutils'
require 'dassets/source_file'
require 'dassets/asset_file'

class Dassets::AssetFile

  class BaseTests < Assert::Context
    desc "Dassets::AssetFile"
    setup do
      @asset_file = Dassets::AssetFile.new('file1.txt', 'abc123')
    end
    subject{ @asset_file }

    should have_readers :path, :dirname, :extname, :basename, :output_path
    should have_imeths  :fingerprint, :content, :url, :href, :source_file
    should have_imeths  :mtime, :size, :mime_type, :exists?, :==

    should "know its digest path, dirname, extname, and basename" do
      assert_equal 'file1.txt', subject.path
      assert_equal '.',     subject.dirname
      assert_equal '.txt',  subject.extname
      assert_equal 'file1', subject.basename
    end

    should "know it's mtime, size, mime_type, and if it exists" do
      assert_equal File.mtime(subject.output_path).httpdate, subject.mtime
      assert_equal File.size?(subject.output_path), subject.size
      assert_equal "text/plain", subject.mime_type
      assert subject.exists?

      null_file = Dassets::AssetFile.new('', '')
      assert_nil null_file.mtime
      assert_nil null_file.size
      assert_nil null_file.mime_type
      assert_not null_file.exists?
    end

    should "build it's output_path from the path" do
      assert_equal "#{Dassets.config.output_path}/file1.txt", subject.output_path

      nested = Dassets::AssetFile.new('nested/file1.txt', 'abc123')
      assert_equal "#{Dassets.config.output_path}/nested/file1.txt", nested.output_path
    end

    should "know its source file" do
      assert_not_nil subject.source_file
      assert_kind_of Dassets::SourceFile, subject.source_file
      assert_equal subject.path, subject.source_file.digest_path
    end

    should "know its fingerprint" do
      assert_equal 'abc123', subject.fingerprint
    end

    should "get its fingerprint from its source file if none is given" do
      af = Dassets::AssetFile.new('file1.txt')
      assert_equal af.source_file.fingerprint, af.fingerprint
    end

    should "know it's content" do
      assert_equal "file1.txt\n", subject.content

      null_file = Dassets::AssetFile.new('', '')
      assert_nil null_file.content
    end

    should "get its content from its source file if needed" do
      digest_path = 'nested/a-thing.txt.no-use'
      exp_content = "thing\n\nDUMB\nUSELESS"

      with_output = Dassets::AssetFile.new(digest_path)
      assert_equal exp_content, with_output.content

      FileUtils.mv with_output.output_path, "#{with_output.output_path}.bak"
      without_output = Dassets::AssetFile.new(digest_path)
      assert_equal exp_content, without_output.content
      FileUtils.mv "#{with_output.output_path}.bak", with_output.output_path
    end

    should "build it's url from the path and the fingerprint" do
      assert_equal "file1-abc123.txt", subject.url

      nested = Dassets::AssetFile.new('nested/file1.txt', 'abc123')
      assert_equal "nested/file1-abc123.txt", nested.url
    end

    should "build it's href from the url" do
      assert_equal "/file1-abc123.txt", subject.href

      nested = Dassets::AssetFile.new('nested/file1.txt', 'abc123')
      assert_equal "/nested/file1-abc123.txt", nested.href
    end

  end

end
