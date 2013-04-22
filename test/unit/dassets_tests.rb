require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class BaseTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :sources, :digests, :[]

    should "return a `Config` instance with the `config` method" do
      assert_kind_of Config, subject.config
    end

    should "read the source list on init" do
      subject.reset
      assert_empty subject.sources

      subject.init
      assert_not_empty subject.sources
    end

    should "read/parse the digests on init" do
      subject.reset
      assert_empty subject.digests

      subject.init
      assert_not_empty subject.digests
    end

    should "return asset files given a their path using the index operator" do
      subject.init
      file = subject['nested/file3.txt']

      assert_kind_of Dassets::AssetFile, file
      assert_equal 'nested/file3.txt', file.path
      assert_equal 'd41d8cd98f00b204e9800998ecf8427e', file.md5

      subject.reset
    end

    should "return an asset file with no fingerprint if path not in digests" do
      file = subject['path/not/found.txt']
      assert_equal '', file.md5

      subject.init
      file = subject['path/not/found.txt']
      assert_equal '', file.md5

      subject.reset
    end

  end

  class SourceListTests < BaseTests
    desc "source list"

    should "build from the configured source path and filter proc" do
      config = Dassets::Config.new
      config.source_path = "source_files" # test/support/source_files
      exp_list = [
        'test1.txt', '_ignored.txt', 'nested/test2.txt', 'nested/_nested_ignored.txt'
      ].map{ |p| File.expand_path(p, config.source_path) }.sort

      assert_equal exp_list, Dassets::SourceList.new(config)
    end

    should "filter out any paths in the output path" do
      config = Dassets::Config.new
      config.source_path = "source_files" # test/support/source_files
      config.output_path = "source_files/nested"
      exp_list = [
        'test1.txt', '_ignored.txt'
      ].map{ |p| File.expand_path(p, config.source_path) }.sort

      assert_equal exp_list, Dassets::SourceList.new(config)
    end

    should "run the supplied source filter on the paths" do
      config = Dassets::Config.new
      config.source_path = "source_files" # test/support/source_files
      config.source_filter = proc do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      exp_list = [
        'test1.txt', 'nested/test2.txt'
      ].map{ |p| File.expand_path(p, config.source_path) }.sort

      assert_equal exp_list, Dassets::SourceList.new(config)

      config.sources "source_files" do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      assert_equal exp_list, Dassets::SourceList.new(config)
    end

  end

end
