require 'assert'
require 'digest/md5'
require 'dassets/source_file'
require 'dassets/source_cache'

class Dassets::SourceCache

  class BaseTests < Assert::Context
    desc "Dassets::SourceCache"
    setup do
      @source_cache = Dassets::SourceCache.new('file1.txt')
    end
    subject{ @source_cache }

    should have_readers :digest_path, :source_files
    should have_imeths :content, :fingerprint, :key, :mtime, :exists?

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "know its source file" do
      exp_source_file = Dassets::SourceFile.find_by_digest_path('file1.txt')
      assert_equal 1, subject.source_files.size
      assert_equal exp_source_file, subject.source_files.first
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
      exp_fp = Digest::MD5.new.hexdigest(subject.source_files.first.compiled)
      assert_equal exp_fp, subject.fingerprint
    end

    should "get its content from the compiled source" do
      assert_equal subject.source_files.first.compiled, subject.content
    end

  end

  # TODO: tests where combinations result in multiple source files

end
