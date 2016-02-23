require 'assert'
require 'dassets/source_proxy'

require 'digest/md5'
require 'dassets/cache'
require 'dassets/source_file'
require 'dassets/source_proxy'

class Dassets::SourceProxy

  class UnitTests < Assert::Context
    desc "Dassets::SourceProxy"
    setup do
      @source_proxy = Dassets::SourceProxy.new(Factory.string)
    end
    subject{ @source_proxy }

    should have_readers :digest_path, :content_cache, :fingerprint_cache
    should have_readers :source_files
    should have_imeths :key, :content, :fingerprint, :mtime, :response_headers
    should have_imeths :exists?

  end

  class NotComboTests < UnitTests
    desc "when the digest path is not a combination"
    setup do
      @source_proxy = Dassets::SourceProxy.new('file1.txt')
    end

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "use no cache by default" do
      assert_kind_of Dassets::Cache::NoCache, subject.content_cache
      assert_kind_of Dassets::Cache::NoCache, subject.fingerprint_cache
    end

    should "have a single source file" do
      assert_equal 1, subject.source_files.size
      exp = Dassets::SourceFile.find_by_digest_path('file1.txt')
      assert_equal exp, subject.source_files.first
    end

    should "use its digest path and mtime as its key" do
      exp = "#{subject.digest_path} -- #{subject.mtime}"
      assert_equal exp, subject.key
    end

    should "get its content from the compiled source of the single source file" do
      assert_equal subject.source_files.first.compiled, subject.content
    end

    should "get its fingerprint by MD5 hashing the content" do
      exp = Digest::MD5.new.hexdigest(subject.content)
      assert_equal exp, subject.fingerprint
    end

    should "use its single source file's max mtime as its mtime" do
      assert_equal subject.source_files.first.mtime, subject.mtime
    end

    should "use its single source file's response headers as its resonse headers" do
      assert_equal subject.source_files.first.response_headers, subject.response_headers
    end

    should "exist if its single source file exists" do
      assert_equal subject.source_files.first.exists?, subject.exists?
    end

  end

  class ComboSetupTests < UnitTests
    setup do
      Dassets.config.combination 'file3.txt', ['file1.txt', 'file2.txt']
      Dassets.config.combination 'file4.txt', []
      Dassets.config.combination 'file5.txt', ['file3.txt', 'file4.txt']
    end
    teardown do
      Dassets.config.combinations.delete('file5.txt')
      Dassets.config.combinations.delete('file4.txt')
      Dassets.config.combinations.delete('file3.txt')
    end

  end

  class ComboTests < ComboSetupTests
    desc "when the digest path is a combination to multiple source files"
    setup do
      @exp_source_files = [
        Dassets::SourceFile.find_by_digest_path('file1.txt'),
        Dassets::SourceFile.find_by_digest_path('file2.txt')
      ]
      @source_proxy = Dassets::SourceProxy.new('file3.txt')
    end

    should "know its digest path" do
      assert_equal 'file3.txt', subject.digest_path
    end

    should "know its source files" do
      assert_equal 2, subject.source_files.size
      assert_equal @exp_source_files, subject.source_files
    end

    should "get its content from the compiled source of its source files" do
      exp = subject.source_files.map{ |f| f.compiled }.join("\n")
      assert_equal exp, subject.content
    end

    should "use its source files' max mtime as its mtime" do
      exp = subject.source_files.map{ |f| f.mtime }.max
      assert_equal exp, subject.mtime
    end

    should "use its source files' merged response headers as its response headers" do
      exp = subject.source_files.inject(Hash.new) do |hash, file|
        hash.merge!(file.response_headers)
      end
      assert_equal exp, subject.response_headers
    end

    should "exist if its all its source files exist" do
      exp = subject.source_files.inject(true){ |res, f| res && f.exists? }
      assert_equal exp, subject.exists?
    end

  end

  class EmptyComboTests < ComboSetupTests
    desc "when the digest path is an empty combination"
    setup do
      @source_proxy = Dassets::SourceProxy.new('file4.txt')
    end

    should "not have any source files" do
      assert_equal 0, subject.source_files.size
    end

    should "have empty content" do
      assert_equal '', subject.content
    end

    should "have no mtime" do
      assert_nil subject.mtime
    end

    should "exist" do
      assert_true subject.exists?
    end

  end

  class ComboWithEmptyComboTests < ComboSetupTests
    desc "when the digest path is a combination that includes an empty combination"
    setup do
      @source_proxy = Dassets::SourceProxy.new('file5.txt')
    end

    should "ignore the mtime of the empty combination" do
      exp_mtime = subject.source_files.map{ |f| f.mtime }.compact.max
      assert_equal exp_mtime, subject.mtime
    end

  end

  class NoCacheTests < UnitTests
    desc "with a `NoCache` cache handler"
    setup do
      @cache = Dassets::Cache::NoCache.new
      @source_proxy = Dassets::SourceProxy.new('file1.txt', {
        :content_cache     => @cache,
        :fingerprint_cache => @cache
      })
    end

    should "not cache its source content/fingerprint" do
      content1 = subject.content
      content2 = subject.content
      assert_not_same content2, content1

      finger1 = subject.fingerprint
      finger2 = subject.fingerprint
      assert_not_same finger2, finger1
    end

  end

  class MemCacheTests < UnitTests
    desc "with a `MemCache` cache handler"
    setup do
      @content_cache     = Dassets::Cache::MemCache.new
      @fingerprint_cache = Dassets::Cache::MemCache.new
      @source_proxy = Dassets::SourceProxy.new('file1.txt', {
        :content_cache     => @content_cache,
        :fingerprint_cache => @fingerprint_cache
      })
    end

    should "cache its source content/fingerprint in memory" do
      content1 = subject.content
      content2 = subject.content
      assert_same content2, content1

      finger1 = subject.fingerprint
      finger2 = subject.fingerprint
      assert_same finger2, finger1
    end

  end

end
