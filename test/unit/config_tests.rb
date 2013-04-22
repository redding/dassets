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

    should have_option :root_path,   Pathname, :required => true
    should have_option :assets_file, Pathname, :default => ENV['DASSETS_ASSETS_FILE']
    should have_options :source_path, :output_path, :digests_path
    should have_imeth :sources

    should "should use `apps/assets` as the default source path" do
      exp_path = Dassets.config.root_path.join("app/assets").to_s
      assert_equal exp_path, subject.source_path
    end

    should "should use `apps/assets/public` as the default output path" do
      exp_path = Dassets.config.root_path.join("app/assets/public").to_s
      assert_equal exp_path, subject.output_path
    end

    should "should use `app/assets/.digests` as the default digests file path" do
      exp_path = Dassets.config.root_path.join("app/assets/.digests").to_s
      assert_equal exp_path, subject.digests_path.to_s
    end

    should "set the source path and filter proc with the `sources` method" do
      path = Dassets::RootPath.new 'app/asset_files'
      filter = proc{ |paths| [] }

      subject.sources(path, &filter)
      assert_equal path, subject.source_path
      assert_equal filter, subject.source_filter
    end



    # deprecated
    should have_options :files_path

    should "should use `apps/assets/public` as the default files path" do
      exp_path = Dassets.config.root_path.join("app/assets/public").to_s
      assert_equal exp_path, subject.files_path
    end

  end

end
