require 'assert'
require 'dassets'
require 'dassets/cmds/digest_cmd'

class Dassets::Cmds::DigestCmd

  class BaseTests < Assert::Context
    desc "Dassets::Cmds::DigestCmd"
    setup do
      @cmd = Dassets::Cmds::DigestCmd.new(['a/path'])
    end
    subject{ @cmd }

    should have_readers :paths
    should have_instance_method :run

    should "know it's paths" do
      assert_equal ['a/path'], subject.paths
    end

  end

end
