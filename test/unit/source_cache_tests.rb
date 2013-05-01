require 'assert'
require 'dassets/source_file'
require 'dassets/source_cache'

class Dassets::SourceCache

  class BaseTests < Assert::Context
    desc "Dassets::SourceCache"
    setup do
      @source_cache = Dassets::SourceCache.new('file1.txt')
    end
    subject{ @source_cache }

    test have_readers :digest_path, :source_file
    should have_imeths :content, :fingerprint, :key, :mtime, :exists?

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "know its source file" do
      exp_source_file = Dassets::SourceFile.find_by_digest_path('file1.txt')
      assert_equal exp_source_file, subject.source_file
    end

    should "exist if its source file exists" do
      assert_equal subject.source_file.exists?, subject.exists?
    end

    should "use its source file's mtime as its mtime" do
      assert_equal subject.source_file.mtime, subject.mtime
    end

    should "use its digest path and mtime as its key" do
      exp_key = "#{subject.digest_path} -- #{subject.mtime}"
      assert_equal exp_key, subject.key
    end

    should "get its fingerprint from the source file" do
      assert_equal subject.source_file.fingerprint, subject.fingerprint
    end

    should "get its content from the source file" do
      assert_equal subject.source_file.compiled, subject.content
    end


  end

end
