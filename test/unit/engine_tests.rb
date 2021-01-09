# frozen_string_literal: true

require "assert"
require "dassets/engine"

class Dassets::Engine
  class UnitTests < Assert::Context
    desc "Dassets::Engine"
    subject{ Dassets::Engine.new }

    should have_reader :opts
    should have_imeths :ext, :compile

    should "default the opts if none given" do
      exp_opts = {}
      assert_that(subject.opts).equals(exp_opts)
    end

    should "raise NotImplementedError on `ext` and `compile`" do
      assert_that{ subject.ext("foo") }.raises(NotImplementedError)
      assert_that{ subject.compile("some content") }
        .raises(NotImplementedError)
    end
  end
end
