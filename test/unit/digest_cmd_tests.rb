require 'assert'
require 'dassets'
require 'dassets/digest_cmd'

class Dassets::DigestCmd

  class BaseTests < Assert::Context
    desc "Dassets::DigestCmd"
    setup do
      @cmd = Dassets::DigestCmd.new(['a/path'])
    end
    subject{ @cmd }

    should have_readers :paths
    should have_instance_method :run

    should "know it's paths" do
      assert_equal ['a/path'], subject.paths
    end

  end

end
