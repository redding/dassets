# frozen_string_literal: true

require "assert"
require "dassets/source_file"

require "dassets/asset_file"
require "dassets/cache"
require "dassets/source_proxy"

class Dassets::SourceFile
  class UnitTests < Assert::Context
    desc "Dassets::SourceFile"
    subject{ Dassets::SourceFile.new(@file_path) }

    setup do
      @file_path = TEST_SUPPORT_PATH.join("app/assets/file1.txt").to_s
    end

    should have_readers :file_path
    should have_imeths :source, :asset_file, :digest_path
    should have_imeths :compiled, :exists?, :mtime
    should have_imeths :base_path, :response_headers
    should have_cmeth :find_by_digest_path

    should "know its file path" do
      assert_that(subject.file_path).equals(@file_path.to_s)
    end

    should "know its configured source" do
      exp_source =
        Dassets.config.sources.select{ |s| @file_path.include?(s.path) }.last
      assert_that(subject.source).equals(exp_source)
    end

    should "know its asset file" do
      assert_that(subject.asset_file).is_kind_of(Dassets::AssetFile)
      assert_that(subject.asset_file)
        .equals(Dassets::AssetFile.new(subject.digest_path))
    end

    should "know its digest path" do
      assert_that(subject.digest_path).equals("file1.txt")
    end

    should "not memoize its compiled source" do
      compiled1 = subject.compiled
      compiled2 = subject.compiled
      assert_that(compiled2).is_not(compiled1)
    end

    should "know if it exists" do
      assert_that(subject.exists?).is_true
    end

    should "use the mtime of its file as its mtime" do
      assert_that(subject.mtime).equals(File.mtime(subject.file_path))
    end

    should "use the response headers of its source as its response headers" do
      assert_that(subject.response_headers).is(subject.source.response_headers)
    end

    should "use the base path of its source as its base path" do
      assert_that(subject.base_path).equals(subject.source.base_path.to_s)
    end

    should "be findable by its digest path" do
      found = Dassets::SourceFile.find_by_digest_path(subject.digest_path)

      assert_that(found).equals(subject)
      assert_that(found).is_not(subject)
    end
  end

  class EngineTests < UnitTests
    desc "compiled against engines"

    setup do
      @file_path =
        TEST_SUPPORT_PATH.join("app/assets/nested/a-thing.txt.useless.dumb")
    end

    should "build the digest path appropriately" do
      assert_that(subject.digest_path).equals("nested/a-thing.txt.no-use")
    end

    should "compile the source content appropriately" do
      file_content = File.read(@file_path)
      exp_compiled_content = [file_content, "DUMB", "USELESS"].join("\n")
      assert_that(subject.compiled).equals(exp_compiled_content)
    end
  end
end

class Dassets::NullSourceFile
  class UnitTests < Assert::Context
    setup do
      Dassets.config.combination "file3.txt", ["file1.txt", "file2.txt"]
    end

    teardown do
      Dassets.config.combinations.delete("file3.txt")
    end

    should "find a null src file if finding by an unknown digest path" do
      null_src = Dassets::NullSourceFile.new("not/found/digest/path")
      found = Dassets::SourceFile.find_by_digest_path("not/found/digest/path")

      assert_that(found).equals(null_src)
      assert_that(found).is_not(null_src)

      assert_that(null_src.file_path).equals("")
      assert_that(null_src.exists?).equals(false)
      assert_that(null_src.compiled).is_nil
      assert_that(null_src.mtime).is_nil
      assert_that(null_src.response_headers).equals({})
    end

    should "pass options to a null src when finding by an unknown digest "\
           "path" do
      null_src = Dassets::NullSourceFile.new("not/found/digest/path")
      null_src_new_called_with = []
      Assert.stub(Dassets::NullSourceFile, :new) do |*args|
        null_src_new_called_with = args
        null_src
      end

      options = {
        content_cache: Dassets::NoCache.new,
        fingerprint_cache: Dassets::NoCache.new,
      }
      Dassets::SourceFile.find_by_digest_path(
        "not/found/digest/path",
        **options,
      )

      exp = ["not/found/digest/path", options]
      assert_that(null_src_new_called_with).equals(exp)
    end

    should "proxy the digest path if the path is a combination" do
      src_proxy      = Dassets::SourceProxy.new("file3.txt")
      null_combo_src = Dassets::NullSourceFile.new("file3.txt")

      assert_that(null_combo_src.exists?).equals(src_proxy.exists?)
      assert_that(null_combo_src.compiled).equals(src_proxy.content)
      assert_that(null_combo_src.mtime).equals(src_proxy.mtime)
    end

    should "pass options to its source proxy when the path is a combination" do
      src_proxy = Dassets::SourceProxy.new("file3.txt")
      src_proxy_new_called_with = []
      Assert.stub(Dassets::SourceProxy, :new) do |*args|
        src_proxy_new_called_with = args
        src_proxy
      end

      options = {
        content_cache: Dassets::NoCache.new,
        fingerprint_cache: Dassets::NoCache.new,
      }
      Dassets::NullSourceFile.new("file3.txt", **options)

      exp = ["file3.txt", options]
      assert_that(src_proxy_new_called_with).equals(exp)
    end
  end
end
