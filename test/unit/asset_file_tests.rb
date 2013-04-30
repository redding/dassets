require 'assert'
require 'fileutils'
require 'dassets/source_file'
require 'dassets/asset_file'

class Dassets::AssetFile

  class BaseTests < Assert::Context
    desc "Dassets::AssetFile"
    setup do
      @asset_file = Dassets::AssetFile.new('file1.txt')
    end
    subject{ @asset_file }

    should have_readers :path, :dirname, :extname, :basename, :source_file
    should have_imeths  :digest!, :url, :fingerprint, :content
    should have_imeths  :href, :mtime, :size, :mime_type, :exists?, :==

    should "know its digest path, dirname, extname, and basename" do
      assert_equal 'file1.txt', subject.path
      assert_equal '.',     subject.dirname
      assert_equal '.txt',  subject.extname
      assert_equal 'file1', subject.basename
    end

    should "use its source mtime as its mtime" do
      assert_equal subject.source_file.mtime, subject.mtime
      assert_equal Rack::Utils.bytesize(subject.content), subject.size
      assert_equal "text/plain", subject.mime_type
      assert subject.exists?

      null_file = Dassets::AssetFile.new('')
      assert_nil null_file.mtime
      assert_nil null_file.size
      assert_nil null_file.mime_type
      assert_not null_file.exists?
    end

    should "know its source file" do
      assert_not_nil subject.source_file
      assert_kind_of Dassets::SourceFile, subject.source_file
      assert_equal subject.path, subject.source_file.digest_path
    end

    should "have a fingerprint" do
      assert_not_nil subject.fingerprint
    end

    should "get its fingerprint from its source file if none is given" do
      af = Dassets::AssetFile.new('file1.txt')
      assert_equal af.source_file.fingerprint, af.fingerprint
    end

    should "know it's content" do
      assert_equal "file1.txt\n", subject.content

      null_file = Dassets::AssetFile.new('')
      assert_nil null_file.content
    end

    should "get its content from its source file if no output file" do
      digest_path = 'nested/a-thing.txt.no-use'
      exp_content = "thing\n\nDUMB\nUSELESS"

      without_output = Dassets::AssetFile.new(digest_path)
      assert_equal exp_content, without_output.content
    end

    should "build it's url from the path and the fingerprint" do
      assert_match /^file1-[a-f0-9]{32}\.txt$/, subject.url

      nested = Dassets::AssetFile.new('nested/file1.txt')
      assert_equal "nested/file1-.txt", nested.url
    end

    should "build it's href from the url" do
      assert_match /^\/file1-[a-f0-9]{32}\.txt$/, subject.href

      nested = Dassets::AssetFile.new('nested/file1.txt')
      assert_equal "/nested/file1-.txt", nested.href
    end

  end

  class DigestTests < BaseTests
    desc "being digested with an output path configured"
    setup do
      Dassets.config.output_path = 'public'
      @url = @asset_file.digest!
    end
    teardown do
      Dassets.config.output_path = nil
    end

    should "return the asset file url" do
      assert_equal @asset_file.url, @url
    end

    should "compile and write an asset file to the output path" do
      outfile = File.join(Dassets.config.output_path, @url)

      assert_file_exists outfile
      assert_equal subject.content, File.read(outfile)
    end

  end

end
