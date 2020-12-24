require "assert"
require "dassets"

require "fileutils"
require "dassets/asset_file"

module Dassets
  class UnitTests < Assert::Context
    desc "Dassets"
    subject { Dassets }

    should have_imeths :config, :configure, :init, :reset
    should have_imeths :asset_file, :[], :source_files, :combinations

    should "return a `Config` instance with the `config` method" do
      assert_that(subject.config).is_kind_of(Dassets::Config)
    end

    should "know how to reset itself" do
      config_reset_called = false
      Assert.stub(subject.config, :reset) { config_reset_called = true }

      file1 = subject["nested/file3.txt"]

      subject.reset

      file2 = subject["nested/file3.txt"]
      assert_that(file2).is_not_the_same_as(file1)
      assert_that(config_reset_called).is_true
    end

    should "return asset files given their digest path " do
      file = subject.asset_file("nested/file3.txt")

      assert_that(file).is_kind_of(subject::AssetFile)
      assert_that(file.digest_path).equals("nested/file3.txt")
      assert_that(file.fingerprint).equals("d41d8cd98f00b204e9800998ecf8427e")
    end

    should "cache asset files" do
      file1 = subject.asset_file("nested/file3.txt")
      file2 = subject.asset_file("nested/file3.txt")

      assert_that(file2).is_the_same_as(file1)
    end

    should "complain if digest path is not found using the index operator" do
      assert_that(-> {
        subject.asset_file("path/not/found.txt")
      }).does_not_raise

      assert_that(-> {
        subject["path/not/found.txt"]
      }).raises(AssetFileError)
    end

    should "know its list of configured source files" do
      exp = Dassets::SourceFiles.new(subject.config.sources)
      assert_that(subject.source_files).equals(exp)
    end

    should "know its configured combinations" do
      exp = subject.config.combinations
      assert_that(subject.combinations).equals(exp)
    end
  end
end
