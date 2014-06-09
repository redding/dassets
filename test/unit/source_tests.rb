require 'assert'
require 'dassets/source'

require 'dassets/engine'

class Dassets::Source

  class UnitTests < Assert::Context
    desc "Dassets::Source"
    setup do
      @source_path = TEST_SUPPORT_PATH.join("source_files")
      @source = Dassets::Source.new(@source_path)
    end
    subject{ @source }

    should have_reader :path, :engines
    should have_imeth :files, :filter, :engine

    should "know its path and default filter" do
      assert_equal @source_path.to_s, subject.path
      assert_kind_of Proc, subject.filter
      assert_equal ['file1', 'file2'], subject.filter.call(['file1', 'file2'])
    end

    should "know its files" do
      exp_files = [
        @source_path.join('test1.txt').to_s,
        @source_path.join('_ignored.txt').to_s,
        @source_path.join('nested/test2.txt').to_s,
        @source_path.join('nested/_nested_ignored.txt').to_s
      ].sort
      assert_equal exp_files, subject.files
    end

    should "run the supplied source filter on the paths" do
      subject.filter do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      exp_files = [
        @source_path.join('test1.txt').to_s,
        @source_path.join('nested/test2.txt').to_s,
      ].sort

      assert_equal exp_files, subject.files
    end

    should "know its engines and return a NullEngine by default" do
      assert_kind_of ::Hash, subject.engines
      assert_kind_of Dassets::NullEngine, subject.engines['something']
    end

  end

  class EmptySourceTests < UnitTests
    desc "with no source files"
    setup do
      @empty_source_path = TEST_SUPPORT_PATH.join("empty")
      @empty_source = Dassets::Source.new(@empty_source_path)

      @no_exist_source_path = TEST_SUPPORT_PATH.join("does-not-exist")
      @no_exist_source = Dassets::Source.new(@no_exist_source_path)
    end

    should "have no files" do
      assert_empty @empty_source.files
      assert_empty @no_exist_source.files
    end

    should "hand filters an empty path list" do
      @empty_source.filter do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      @no_exist_source.filter do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end

      assert_empty @empty_source.files
      assert_empty @no_exist_source.files
    end

  end

  class EngineRegistrationTests < UnitTests
    desc "when registering an engine"
    setup do
      @empty_engine = Class.new(Dassets::Engine) do
        def ext(input_ext); ''; end
        def compile(input); ''; end
      end
    end

    should "allow registering new engines" do
      assert_kind_of Dassets::NullEngine, subject.engines['empty']
      subject.engine 'empty', @empty_engine, 'an' => 'opt'
      assert_kind_of @empty_engine, subject.engines['empty']
      assert_equal 'opt', subject.engines['empty'].opts['an']
      assert_equal '', subject.engines['empty'].ext('empty')
      assert_equal '', subject.engines['empty'].compile('some content')
    end

    should "register with the source path as a default option" do
      subject.engine 'empty', @empty_engine
      exp_opts = { 'source_path' => subject.path }
      assert_equal exp_opts, subject.engines['empty'].opts

      subject.engine 'empty', @empty_engine, 'an' => 'opt'
      exp_opts = {
        'source_path' => subject.path,
        'an' => 'opt'
      }
      assert_equal exp_opts, subject.engines['empty'].opts

      subject.engine 'empty', @empty_engine, 'source_path' => 'something'
      exp_opts = { 'source_path' => 'something' }
      assert_equal exp_opts, subject.engines['empty'].opts
    end

  end

end
