require 'assert'
require 'ns-options/assert_macros'
require 'dassets'

class Dassets::Config

  class BaseTests < Assert::Context
    include NsOptions::AssertMacros
    desc "Dassets::Config"
    setup do
      @config = Dassets::Config.new
    end
    subject{ @config }

    should have_option :assets_file, Pathname,  :default => ENV['DASSETS_ASSETS_FILE']
    should have_options :file_store

    should have_reader :engines, :combinations
    should have_imeth :source, :engine, :combination

    should "register new sources with the `source` method" do
      path = '/path/to/app/assets'
      filter = proc{ |paths| [] }
      subject.source(path, &filter)

      assert_equal 1, subject.sources.size
      assert_kind_of Dassets::Source, subject.sources.first
      assert_equal path, subject.sources.first.path
      assert_equal filter, subject.sources.first.filter
    end

    should "know its engines and return a NullEngine by default" do
      assert_kind_of ::Hash, subject.engines
      assert_kind_of Dassets::NullEngine, subject.engines['some']
      assert_kind_of Dassets::NullEngine, subject.engines['thing']
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

    should "know its combinations and return the keyed digest path by default" do
      assert_kind_of ::Hash, subject.combinations
      assert_equal ['some/digest.path'], subject.combinations['some/digest.path']
    end

    should "allow registering new combinations" do
      assert_equal ['some/digest.path'], subject.combinations['some/digest.path']
      exp_combination = ['some/other.path', 'and/another.path']
      subject.combination 'some/digest.path', exp_combination
      assert_equal exp_combination, subject.combinations['some/digest.path']

      assert_equal ['test/digest.path'], subject.combinations['test/digest.path']
      subject.combination 'test/digest.path', ['some/other.path']
      assert_equal ['some/other.path'], subject.combinations['test/digest.path']
    end

  end

end
