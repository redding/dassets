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

    should have_option :root_path, Pathname, :required => true
    should have_option :assets_file, Pathname, :default => ENV['DASSETS_ASSETS_FILE']
    should have_options :source_path, :source_filter, :file_store

    should have_reader :engines
    should have_imeth :source, :engine

    should "should use `apps/assets` as the default source path" do
      exp_path = Dassets.config.root_path.join("app/assets").to_s
      assert_equal exp_path, subject.source_path
    end

    should "set the source path and filter proc with the `sources` method" do
      path = Dassets::RootPath.new 'app/asset_files'
      filter = proc{ |paths| [] }

      subject.source(path, &filter)
      assert_equal path, subject.source_path
      assert_equal filter, subject.source_filter
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

  end

end
