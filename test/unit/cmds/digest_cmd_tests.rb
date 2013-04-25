require 'assert'
require 'dassets'
require 'dassets/cmds/digest_cmd'

class Dassets::Cmds::DigestCmd

  class BaseTests < Assert::Context
    desc "Dassets::Cmds::DigestCmd"
    setup do
      @cmd = Dassets::Cmds::DigestCmd.new(['a/path'], {'some' => 'opts'})
    end
    subject{ @cmd }

    should have_readers :source_paths, :opts
    should have_instance_method :run
    should have_class_method :for

    should "know it's source files and opts" do
      assert_equal(['a/path'], subject.source_paths)
      assert_equal({'some' => 'opts'}, subject.opts)
    end

    should "clear the output path and digests if run for no specific paths" do
      exp_opts = {
        :clear_output_path => Dassets.config.output_path,
        :clear_digests     => Dassets.digests
      }
      assert_equal exp_opts, Dassets::Cmds::DigestCmd.for([]).opts

      exp_opts = {}
      assert_equal exp_opts, Dassets::Cmds::DigestCmd.for(['a/path']).opts
    end

    should "run on all of the sources if run for no specific paths" do
      exp_sources = Dassets::SourceList.new(Dassets.config)
      assert_equal exp_sources, Dassets::Cmds::DigestCmd.for([]).source_paths
    end

  end

end
