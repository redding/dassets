require "assert"
require "dassets/source_proxy"

require "digest/md5"
require "dassets/cache"
require "dassets/source_file"
require "dassets/source_proxy"

class Dassets::SourceProxy
  class UnitTests < Assert::Context
    desc "Dassets::SourceProxy"
    subject { Dassets::SourceProxy.new(Factory.string) }

    should have_readers :digest_path, :content_cache, :fingerprint_cache
    should have_readers :source_files
    should have_imeths :key, :content, :fingerprint, :mtime, :response_headers
    should have_imeths :exists?
  end

  class NotComboTests < UnitTests
    desc "when the digest path is not a combination"
    subject { Dassets::SourceProxy.new("file1.txt") }

    should "know its digest path" do
      assert_that(subject.digest_path).equals("file1.txt")
    end

    should "use no cache by default" do
      assert_that(subject.content_cache).is_kind_of(Dassets::NoCache)
      assert_that(subject.fingerprint_cache).is_kind_of(Dassets::NoCache)
    end

    should "have a single source file" do
      assert_that(subject.source_files.size).equals(1)
      exp = Dassets::SourceFile.find_by_digest_path("file1.txt")
      assert_that(subject.source_files.first).equals(exp)
    end

    should "use its digest path and mtime as its key" do
      exp = "#{subject.digest_path} -- #{subject.mtime}"
      assert_that(subject.key).equals(exp)
    end

    should "get its content from the compiled source of the single source file" do
      assert_that(subject.content).equals(subject.source_files.first.compiled)
    end

    should "get its fingerprint by MD5 hashing the content" do
      exp = Digest::MD5.new.hexdigest(subject.content)
      assert_that(subject.fingerprint).equals(exp)
    end

    should "use its single source file's max mtime as its mtime" do
      assert_that(subject.mtime).equals(subject.source_files.first.mtime)
    end

    should "use its single source file's response headers as its resonse headers" do
      assert_that(subject.response_headers)
        .equals(subject.source_files.first.response_headers)
    end

    should "exist if its single source file exists" do
      assert_that(subject.exists?).equals(subject.source_files.first.exists?)
    end
  end

  class ComboSetupTests < UnitTests
    setup do
      Dassets.config.combination "file3.txt", ["file1.txt", "file2.txt"]
      Dassets.config.combination "file4.txt", []
      Dassets.config.combination "file5.txt", ["file3.txt", "file4.txt"]
    end

    teardown do
      Dassets.config.combinations.delete("file5.txt")
      Dassets.config.combinations.delete("file4.txt")
      Dassets.config.combinations.delete("file3.txt")
    end
  end

  class ComboTests < ComboSetupTests
    desc "when the digest path is a combination to multiple source files"
    subject { Dassets::SourceProxy.new("file3.txt") }

    setup do
      @exp_source_files = [
        Dassets::SourceFile.find_by_digest_path("file1.txt"),
        Dassets::SourceFile.find_by_digest_path("file2.txt")
      ]
    end

    should "know its digest path" do
      assert_that(subject.digest_path).equals("file3.txt")
    end

    should "know its source files" do
      assert_that(subject.source_files.size).equals(2)
      assert_that(subject.source_files).equals(@exp_source_files)
    end

    should "get its content from the compiled source of its source files" do
      exp = subject.source_files.map { |f| f.compiled }.join("\n")
      assert_that(subject.content).equals(exp)
    end

    should "use its source files' max mtime as its mtime" do
      exp = subject.source_files.map { |f| f.mtime }.max
      assert_that(subject.mtime).equals(exp)
    end

    should "use its source files' merged response headers as its response headers" do
      exp =
        subject.source_files.reduce(Hash.new) { |hash, file|
          hash.merge!(file.response_headers)
        }
      assert_that(subject.response_headers).equals(exp)
    end

    should "exist if its all its source files exist" do
      exp = subject.source_files.reduce(true) { |res, f| res && f.exists? }
      assert_that(subject.exists?).equals(exp)
    end
  end

  class EmptyComboTests < ComboSetupTests
    desc "when the digest path is an empty combination"
    subject { Dassets::SourceProxy.new("file4.txt") }

    should "not have any source files" do
      assert_that(subject.source_files.size).equals(0)
    end

    should "have empty content" do
      assert_that(subject.content).equals("")
    end

    should "have no mtime" do
      assert_that(subject.mtime).is_nil
    end

    should "exist" do
      assert_that(subject.exists?).is_true
    end
  end

  class ComboWithEmptyComboTests < ComboSetupTests
    desc "when the digest path is a combination that includes an empty "\
         "combination"
    subject { Dassets::SourceProxy.new("file5.txt") }

    should "ignore the mtime of the empty combination" do
      exp_mtime = subject.source_files.map { |f| f.mtime }.compact.max
      assert_that(subject.mtime).equals(exp_mtime)
    end
  end

  class NoCacheTests < UnitTests
    desc "with a `NoCache` cache handler"
    subject {
      cache = Dassets::NoCache.new
      Dassets::SourceProxy.new(
        "file1.txt",
        content_cache:     cache,
        fingerprint_cache: cache,
      )
    }

    should "not cache its source content/fingerprint" do
      content1 = subject.content
      content2 = subject.content
      assert_that(content2).is_not_the_same_as(content1)

      finger1 = subject.fingerprint
      finger2 = subject.fingerprint
      assert_that(finger2).is_not_the_same_as(finger1)
    end
  end

  class MemCacheTests < UnitTests
    desc "with a `MemCache` cache handler"
    subject {
      content_cache     = Dassets::MemCache.new
      fingerprint_cache = Dassets::MemCache.new

      Dassets::SourceProxy.new(
        "file1.txt",
        content_cache:     content_cache,
        fingerprint_cache: fingerprint_cache,
      )
    }

    should "cache its source content/fingerprint in memory" do
      content1 = subject.content
      content2 = subject.content
      assert_that(content2).is_the_same_as(content1)

      finger1 = subject.fingerprint
      finger2 = subject.fingerprint
      assert_that(finger2).is_the_same_as(finger1)
    end
  end
end
