require 'assert'
require 'dassets/source'

class Dassets::Source

  class BaseTests < Assert::Context
    desc "Dassets::Source"
    setup do
      @source = Dassets::Source.new(TEST_SUPPORT_PATH.join("source_files"))
    end
    subject{ @source }

    should have_readers :path, :filter
    should have_imeth :files

    should "know its path and filter" do
      assert_equal TEST_SUPPORT_PATH.join("source_files"), subject.path
      assert_kind_of Proc, subject.filter
      assert_equal ['file1', 'file2'], subject.filter.call(['file1', 'file2'])
    end

    should "know its files" do
      exp_files = [
        TEST_SUPPORT_PATH.join('source_files/test1.txt').to_s,
        TEST_SUPPORT_PATH.join('source_files/_ignored.txt').to_s,
        TEST_SUPPORT_PATH.join('source_files/nested/test2.txt').to_s,
        TEST_SUPPORT_PATH.join('source_files/nested/_nested_ignored.txt').to_s
      ].sort
      assert_equal exp_files, subject.files
    end

    should "run the supplied source filter on the paths" do
      filter = proc do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      source = Dassets::Source.new(subject.path, &filter)
      exp_files = [
        TEST_SUPPORT_PATH.join('source_files/test1.txt').to_s,
        TEST_SUPPORT_PATH.join('source_files/nested/test2.txt').to_s,
      ].sort

      assert_equal exp_files, source.files
    end

  end

end
