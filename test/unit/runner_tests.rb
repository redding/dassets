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

    should have_readers :cmd_name, :cmd_args, :opts, :root_path

    should "know its cmd, cmd_args, and opts" do
      assert_equal 'null', subject.cmd_name
      assert_equal [1,2],  subject.cmd_args
      assert_equal 'opts', subject.opts['some']
    end

    should "default the 'root_path' opt to `Dir.pwd`" do
      assert_equal Dir.pwd, subject.root_path
    end

  end

  class RunTests < BaseTests
    desc "when running a command"
    setup do
      @orig_root_path = Dassets.config.root_path
      Dassets.config.root_path = nil
      @runner = Dassets::Runner.new(['null', 1, 2], {
        'root_path' => File.join(ROOT_PATH, 'test', 'support')
      })
    end
    teardown do
      Dassets.config.root_path = @orig_root_path
    end

    should "require in the config/dassets.rb file if it exists" do
      assert_nil Dassets.config.root_path
      subject.run
      assert_not_nil Dassets.config.root_path
    end

    should "complain about unknown cmds" do
      runner = Dassets::Runner.new(['unknown'], {})
      assert_raises(UnknownCmdError) { runner.run }
    end

  end

end
