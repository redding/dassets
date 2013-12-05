require 'assert'
require 'dassets'

require 'fileutils'
require 'dassets/asset_file'

module Dassets

  class UnitTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :[]
    should have_imeths :source_list

    should "return a `Config` instance with the `config` method" do
      assert_kind_of Config, subject.config
    end

    should "return asset files given a their digest path using the index operator" do
      file = subject['nested/file3.txt']

      assert_kind_of Dassets::AssetFile, file
      assert_equal 'nested/file3.txt', file.digest_path
      assert_equal 'd41d8cd98f00b204e9800998ecf8427e', file.fingerprint
    end

    should "cache asset files" do
      file1 = subject['nested/file3.txt']
      file2 = subject['nested/file3.txt']

      assert_same file2, file1
    end

    should "return an asset file that doesn't exist if digest path not found" do
      file = subject['path/not/found.txt']
      assert_not file.exists?
    end

    should "know its list of configured source files" do
      exp_configured_list = Dassets::SourceList.new(Dassets.config.sources)
      assert_equal exp_configured_list, subject.source_list
    end

  end

end
