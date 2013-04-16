require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class BaseTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :digests, :[]

    should "return its `Config` class with the `config` method" do
      assert_same Config, subject.config
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

end
