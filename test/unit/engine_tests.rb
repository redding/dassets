require 'assert'
require 'dassets/engine'

class Dassets::Engine

  class UnitTests < Assert::Context
    desc "Dassets::Engine"
    setup do
      @engine = Dassets::Engine.new
    end
    subject{ @engine }

    should have_reader :opts
    should have_imeths :ext, :compile

    should "default the opts if none given" do
      exp_opts = {}
      assert_equal exp_opts, subject.opts
    end

    should "raise NotImplementedError on `ext` and `compile`" do
      assert_raises NotImplementedError do
        subject.ext('foo')
      end

      assert_raises NotImplementedError do
        subject.compile('some content')
      end
    end

  end

  class NullEngineTests < Assert::Context
    desc "Dassets::NullEngine"
    setup do
      @engine = Dassets::NullEngine.new('some' => 'opts')
    end
    subject{ @engine }

    should "be a Engine" do
      assert_kind_of Dassets::Engine, subject
    end

    should "know its opts" do
      exp_opts = {'some' => 'opts'}
      assert_equal exp_opts, subject.opts
    end

    should "return the given extension on `ext`" do
      assert_equal 'foo', subject.ext('foo')
    end

    should "return the given input on `compile" do
      assert_equal 'some content', subject.compile('some content')
    end

  end

end
