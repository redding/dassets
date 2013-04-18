require 'assert'
require 'pathname'
require 'dassets/runner'

class Dassets::Runner

  class BaseTests < Assert::Context
    desc "Dassets::Runner"
    setup do
      @runner = Dassets::Runner.new(['null', 1, 2], 'some' => 'opts')
    end
    subject{ @runner }

    should have_readers :cmd_name, :cmd_args, :opts

    should "know its cmd, cmd_args, and opts" do
      assert_equal 'null', subject.cmd_name
      assert_equal [1,2],  subject.cmd_args
      assert_equal 'opts', subject.opts['some']
    end

    should "complain about unknown cmds" do
      runner = Dassets::Runner.new(['unknown'], {})
      assert_raises(UnknownCmdError) { runner.run }
    end

  end

end
