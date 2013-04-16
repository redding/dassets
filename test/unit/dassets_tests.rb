require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class BaseTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :digests

    should "return its `Config` class with the `config` method" do
      assert_same Config, subject.config
    end

    should "read/parse the digests on init" do
      subject.reset
      assert_empty subject.digests

      subject.init
      assert_not_empty subject.digests
    end

  end

end
