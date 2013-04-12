require 'assert'
require 'dassets'

module Dassets

  class BaseTests < Assert::Context
    desc "Dassets"
    subject{ Dassets }

    should have_imeths :config, :configure, :init, :digests

    should "return its `Config` class with the `config` method" do
      assert_same Config, subject.config
    end

  end

end
