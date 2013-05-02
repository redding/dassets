require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class BaseTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :[]
    should have_imeths :digest_source_files

    should "return a `Config` instance with the `config` method" do
      assert_kind_of Config, subject.config
    end

    should "return asset files given a their digest path using the index operator" do
      file = subject['nested/file3.txt']

      assert_kind_of Dassets::AssetFile, file
      assert_equal 'nested/file3.txt', file.digest_path
      assert_equal 'd41d8cd98f00b204e9800998ecf8427e', file.fingerprint
    end

    should "return an asset file with unknown source if digest path not found" do
      file = subject['path/not/found.txt']

      assert_kind_of Dassets::SourceCache, file.source_cache
      assert_kind_of Dassets::NullSourceFile, file.source_cache.source_file
      assert_not file.source_cache.exists?
    end

    should "complain if trying to init without setting the root path" do
      orig_root = Dassets.config.root_path

      Dassets.config.root_path = nil
      assert_raises(RuntimeError){ Dassets.init }

      Dassets.config.root_path = orig_root
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

      config.source "source_files" do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      assert_equal exp_list, Dassets::SourceList.new(config)
    end

  end

end
