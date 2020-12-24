require "assert"
require "dassets/asset_file"

require "fileutils"
require "dassets/file_store"
require "dassets/source_proxy"

class Dassets::AssetFile
  class UnitTests < Assert::Context
    desc "Dassets::AssetFile"
    subject { @asset_file }

    setup do
      @asset_file = Dassets::AssetFile.new("file1.txt")
    end

    should have_readers :digest_path, :dirname, :extname, :basename, :source_proxy
    should have_imeths  :digest!, :url, :href, :fingerprint, :content
    should have_imeths  :mtime, :size, :mime_type, :exists?, :==

    should "know its digest path, dirname, extname, and basename" do
      assert_that(subject.digest_path).equals("file1.txt")
      assert_that(subject.dirname).equals(".")
      assert_that(subject.extname).equals(".txt")
      assert_that(subject.basename).equals("file1")
    end

    should "use its source proxy attrs as its own" do
      assert_that(subject.mtime).equals(subject.source_proxy.mtime.httpdate)
      assert_that(subject.size).equals(subject.content.bytesize)
      assert_that(subject.mime_type).equals("text/plain")
      assert_that(subject.response_headers)
      .equals(subject.source_proxy.response_headers)
      assert_that(subject.exists?).is_true

      null_file = Dassets::AssetFile.new("")
      assert_that(null_file.mtime).is_nil
      assert_that(null_file.size).is_nil
      assert_that(null_file.mime_type).is_nil
      assert_that(null_file.exists?).is_false
      assert_that(null_file.response_headers)
        .equals(null_file.source_proxy.response_headers)
    end

    should "know its source proxy" do
      source_proxy = subject.source_proxy
      assert_that(source_proxy).is_not_nil
      assert_that(source_proxy).is_kind_of(Dassets::SourceProxy)
      assert_that(source_proxy.digest_path).equals(subject.digest_path)
      assert_that(source_proxy.content_cache)
        .equals(Dassets.config.content_cache)
      assert_that(source_proxy.fingerprint_cache)
        .equals(Dassets.config.fingerprint_cache)
    end

    should "have a fingerprint" do
      assert_that(subject.fingerprint).is_not_nil
    end

    should "get its fingerprint from its source proxy if none is given" do
      af = Dassets::AssetFile.new("file1.txt")
      assert_that(af.fingerprint).equals(af.source_proxy.fingerprint)
    end

    should "know it's content" do
      assert_that(subject.content).equals("file1.txt\n")

      null_file = Dassets::AssetFile.new("")
      assert_that(null_file.content).is_nil
    end

    should "get its content from its source proxy if no output file" do
      digest_path = "nested/a-thing.txt.no-use"
      exp_content = "thing\n\nDUMB\nUSELESS"

      without_output = Dassets::AssetFile.new(digest_path)
      assert_that(without_output.content).equals(exp_content)
    end

    should "build it's url/href from the file, fingerpint, and "\
           "any configured base url" do
      assert_that(subject.url).matches(/^\/file1-[a-f0-9]{32}\.txt$/)
      assert_that(subject.href).matches(subject.url)

      nested = Dassets::AssetFile.new("nested/file1.txt")
      assert_that(nested.url).equals("/nested/file1-.txt")
      assert_that(nested.href).equals(nested.url)

      base_url = Factory.url
      Assert.stub(Dassets.config, :base_url){ base_url }

      assert_that(subject.url).matches(/^#{base_url}\/file1-[a-f0-9]{32}\.txt$/)
      assert_that(subject.href).matches(subject.url)

      assert_that(nested.url).equals("#{base_url}/nested/file1-.txt")
      assert_that(nested.href).equals(nested.url)
    end

    should "not memoize its attributes" do
      url1 = subject.url
      url2 = subject.url
      assert_that(url1).is_not(url2)

      fingerprint1 = subject.fingerprint
      fingerprint2 = subject.fingerprint
      assert_that(fingerprint1).is_not(fingerprint2)

      content1 = subject.content
      content2 = subject.content
      assert_that(content1).is_not(content2)

      mtime1 = subject.mtime
      mtime2 = subject.mtime
      assert_that(mtime1).is_not(mtime2)
    end
  end

  class DigestTests < UnitTests
    desc "being digested with an output path configured"

    setup do
      base_url = Factory.base_url
      Assert.stub(Dassets.config, :base_url){ base_url }
      Dassets.config.file_store TEST_SUPPORT_PATH.join("public").to_s

      @save_path = @asset_file.digest!
      @outfile = Dassets.config.file_store.store_path(@asset_file.url)
    end

    teardown do
      FileUtils.rm_rf(Dassets.config.file_store.root.to_s)
      Dassets.config.file_store Dassets::NullFileStore.new
    end

    should "return the asset file url" do
      assert_that(@save_path).equals(@outfile)
    end

    should "compile and write an asset file to the output path" do
      assert_that(@outfile).is_a_file
      assert_that(File.read(@outfile)).equals(subject.content)
    end
  end
end
