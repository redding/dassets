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
      @source_proxy = Dassets::SourceProxy.new('file1.txt')
    end
    subject{ @source_proxy }

    should have_readers :digest_path, :source_files, :cache
    should have_imeths :content, :fingerprint, :key, :mtime, :exists?

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "know its source files" do
      exp_source_file = Dassets::SourceFile.find_by_digest_path('file1.txt')
      assert_equal 1, subject.source_files.size
      assert_equal exp_source_file, subject.source_files.first
    end

    should "use a `NoCache` cache handler by default" do
      assert_kind_of Dassets::Cache::NoCache, subject.cache
    end

    should "exist if its source file exists" do
      assert_equal subject.source_files.first.exists?, subject.exists?
    end

    should "use its source file's mtime as its mtime" do
      assert_equal subject.source_files.first.mtime, subject.mtime
    end

    should "use its digest path and mtime as its key" do
      exp_key = "#{subject.digest_path} -- #{subject.mtime}"
      assert_equal exp_key, subject.key
    end

    should "get its fingerprint by MD5 hashing the compiled source" do
      exp_fp = Digest::MD5.new.hexdigest(subject.content)
      assert_equal exp_fp, subject.fingerprint
    end

    should "get its content from the compiled source" do
      assert_equal subject.source_files.first.compiled, subject.content
    end

  end

  class CombinationTests < UnitTests
    desc "when the digest path is a combination to multiple source files"
    setup do
      Dassets.config.combination 'file3.txt', ['file1.txt', 'file2.txt']
      @source_proxy = Dassets::SourceProxy.new('file3.txt')
      @exp_source_files = [
        Dassets::SourceFile.find_by_digest_path('file1.txt'),
        Dassets::SourceFile.find_by_digest_path('file2.txt')
      ]
    end
    teardown do
      Dassets.config.combinations.delete('file3.txt')
    end

    should "know its digest path" do
      assert_equal 'file3.txt', subject.digest_path
    end

    should "know its source file" do
      assert_equal 2, subject.source_files.size
      assert_equal @exp_source_files, subject.source_files
    end

    should "exist if its source file exists" do
      exp_exists = @exp_source_files.inject(true){ |res, f| res && f.exists? }
      assert_equal exp_exists, subject.exists?
    end

    should "use its source file's mtime as its mtime" do
      exp_mtime = @exp_source_files.map{ |f| f.mtime }.max
      assert_equal exp_mtime, subject.mtime
    end

    should "get its content from the compiled source" do
      exp_content = @exp_source_files.map{ |f| f.compiled }.join("\n")
      assert_equal exp_content, subject.content
    end

  end

  class NoCacheTests < UnitTests
    desc "with a `NoCache` cache handler"
    setup do
      @cache = Dassets::Cache::NoCache.new
      @source_proxy = Dassets::SourceProxy.new('file1.txt', @cache)
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
      @cache = Dassets::Cache::MemCache.new
      @source_proxy = Dassets::SourceProxy.new('file1.txt', @cache)
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
