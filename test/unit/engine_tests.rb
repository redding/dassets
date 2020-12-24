require "assert"
require "dassets/engine"

class Dassets::Engine
  class UnitTests < Assert::Context
    desc "Dassets::Engine"
    subject { Dassets::Engine.new }

    should have_reader :opts
    should have_imeths :ext, :compile

    should "default the opts if none given" do
      exp_opts = {}
      assert_that(subject.opts).equals(exp_opts)
    end

    should "raise NotImplementedError on `ext` and `compile`" do
      assert_that { subject.ext("foo") }.raises(NotImplementedError)
      assert_that { subject.compile("some content") }
        .raises(NotImplementedError)
    end
  end
end

class Dassets::NullEngine
  class UnitTests < Assert::Context
    desc "Dassets::NullEngine"
    subject { Dassets::NullEngine.new("some" => "opts") }

    should "be a Engine" do
      assert_that(subject).is_kind_of(Dassets::Engine)
    end

    should "know its opts" do
      assert_that(subject.opts).equals({ "some" => "opts" })
    end

    should "return the given extension on `ext`" do
      assert_that(subject.ext("foo")).equals("foo")
    end

    should "return the given input on `compile" do
      assert_that(subject.compile("some content")).equals("some content")
    end
  end
end
