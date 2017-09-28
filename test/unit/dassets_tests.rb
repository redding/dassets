require 'assert'
require 'dassets'

require 'fileutils'
require 'dassets/asset_file'

module Dassets

  class UnitTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :reset
    should have_imeths :[], :source_files, :combinations

    should "return a `Config` instance with the `config` method" do
      assert_kind_of Config, subject.config
    end

    should "know how to reset itself" do
      config_reset_called = false
      Assert.stub(subject.config, :reset){ config_reset_called = true }

      file1 = subject['nested/file3.txt']

      subject.reset

      file2 = subject['nested/file3.txt']
      assert_not_same file2, file1
      assert_true config_reset_called
    end

    should "return asset files given a their digest path using the index operator" do
      file = subject['nested/file3.txt']

      assert_kind_of subject::AssetFile, file
      assert_equal 'nested/file3.txt', file.digest_path
      assert_equal 'd41d8cd98f00b204e9800998ecf8427e', file.fingerprint
    end

    should "cache asset files" do
      file1 = subject['nested/file3.txt']
      file2 = subject['nested/file3.txt']

      assert_same file2, file1
    end

    should "complain if digest path is not found using the index operator" do
      assert_raises AssetFileError do
        subject['path/not/found.txt']
      end
    end

    should "know its list of configured source files" do
      exp = Dassets::SourceFiles.new(subject.config.sources)
      assert_equal exp, subject.source_files
    end

    should "know its configured combinations" do
      exp = subject.config.combinations
      assert_equal exp, subject.combinations
    end

  end

end
