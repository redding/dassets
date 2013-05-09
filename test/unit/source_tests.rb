require 'assert'
require 'dassets/source'

class Dassets::Source

  class BaseTests < Assert::Context
    desc "Dassets::Source"
    setup do
      @source = Dassets::Source.new(TEST_SUPPORT_PATH.join("source_files"))
    end
    subject{ @source }

    should have_reader :path, :engines
    should have_accessor :filter
    should have_imeth :files, :engine

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
      subject.filter = proc do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      exp_files = [
        TEST_SUPPORT_PATH.join('source_files/test1.txt').to_s,
        TEST_SUPPORT_PATH.join('source_files/nested/test2.txt').to_s,
      ].sort

      assert_equal exp_files, subject.files
    end

    should "know its engines and return a NullEngine by default" do
      assert_kind_of ::Hash, subject.engines
      assert_kind_of Dassets::NullEngine, subject.engines['something']
    end

    should "allow registering new engines" do
      empty_engine = Class.new(Dassets::Engine) do
        def ext(input_ext); ''; end
        def compile(input); ''; end
      end

      assert_kind_of Dassets::NullEngine, subject.engines['empty']
      subject.engine 'empty', empty_engine, 'an' => 'opt'
      assert_kind_of empty_engine, subject.engines['empty']

      assert_equal({'an' => 'opt'}, subject.engines['empty'].opts)
      assert_equal '', subject.engines['empty'].ext('empty')
      assert_equal '', subject.engines['empty'].compile('some content')
    end

  end

end
