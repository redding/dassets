require 'assert'
require 'dassets/asset_file'

require 'fileutils'
require 'dassets/file_store'
require 'dassets/source_proxy'

class Dassets::AssetFile

  class UnitTests < Assert::Context
    desc "Dassets::AssetFile"
    setup do
      @asset_file = Dassets::AssetFile.new('file1.txt')
    end
    subject{ @asset_file }

    should have_readers :digest_path, :dirname, :extname, :basename, :source_proxy
    should have_imeths  :digest!, :url, :href, :fingerprint, :content
    should have_imeths  :mtime, :size, :mime_type, :exists?, :==

    should "know its digest path, dirname, extname, and basename" do
      assert_equal 'file1.txt', subject.digest_path
      assert_equal '.',     subject.dirname
      assert_equal '.txt',  subject.extname
      assert_equal 'file1', subject.basename
    end

    should "use its source file attrs as its own" do
      assert_equal subject.source_proxy.mtime.httpdate, subject.mtime
      assert_equal Rack::Utils.bytesize(subject.content), subject.size
      assert_equal "text/plain", subject.mime_type
      assert subject.exists?

      null_file = Dassets::AssetFile.new('')
      assert_nil null_file.mtime
      assert_nil null_file.size
      assert_nil null_file.mime_type
      assert_not null_file.exists?
    end

    should "know its source proxy" do
      assert_not_nil subject.source_proxy
      assert_kind_of Dassets::SourceProxy, subject.source_proxy
      assert_equal subject.digest_path, subject.source_proxy.digest_path
    end

    should "have a fingerprint" do
      assert_not_nil subject.fingerprint
    end

    should "get its fingerprint from its source proxy if none is given" do
      af = Dassets::AssetFile.new('file1.txt')
      assert_equal af.source_proxy.fingerprint, af.fingerprint
    end

    should "know it's content" do
      assert_equal "file1.txt\n", subject.content

      null_file = Dassets::AssetFile.new('')
      assert_nil null_file.content
    end

    should "get its content from its source proxy if no output file" do
      digest_path = 'nested/a-thing.txt.no-use'
      exp_content = "thing\n\nDUMB\nUSELESS"

      without_output = Dassets::AssetFile.new(digest_path)
      assert_equal exp_content, without_output.content
    end

    should "build it's url/href from the file, fingerpint and any configured base url" do
      assert_match /^\/file1-[a-f0-9]{32}\.txt$/, subject.url
      assert_match subject.url, subject.href

      nested = Dassets::AssetFile.new('nested/file1.txt')
      assert_equal "/nested/file1-.txt", nested.url
      assert_equal nested.url, nested.href

      base_url = Factory.url
      Assert.stub(Dassets.config, :base_url){ base_url }

      assert_match /^#{base_url}\/file1-[a-f0-9]{32}\.txt$/, subject.url
      assert_match subject.url, subject.href

      assert_equal "#{base_url}/nested/file1-.txt", nested.url
      assert_equal nested.url, nested.href
    end

    should "not memoize its attributes" do
      url1 = subject.url
      url2 = subject.url
      assert_not_same url2, url1

      fingerprint1 = subject.fingerprint
      fingerprint2 = subject.fingerprint
      assert_not_same fingerprint2, fingerprint1

      content1 = subject.content
      content2 = subject.content
      assert_not_same content2, content1

      mtime1 = subject.mtime
      mtime2 = subject.mtime
      assert_not_same mtime2, mtime1
    end

  end

  class DigestTests < UnitTests
    desc "being digested with an output path configured"
    setup do
      base_url = Factory.base_url
      Assert.stub(Dassets.config, :base_url){ base_url }
      Dassets.config.file_store = TEST_SUPPORT_PATH.join('public').to_s

      @save_path = @asset_file.digest!
      @outfile = Dassets.config.file_store.store_path(@asset_file.url)
    end
    teardown do
      FileUtils.rm(@outfile)
      Dassets.config.file_store = Dassets::FileStore::NullStore.new
    end

    should "return the asset file url" do
      assert_equal @outfile, @save_path
    end

    should "compile and write an asset file to the output path" do
      assert_file_exists @outfile
      assert_equal subject.content, File.read(@outfile)
    end

  end

end
