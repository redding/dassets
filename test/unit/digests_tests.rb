require 'assert'
require 'dassets'
require 'dassets/digests_file'

class Dassets::Digests

  class BaseTests < Assert::Context
    desc "Dassets::Digests"
    subject{ Dassets::Digests }
    setup do
      subject.init(Dassets::Config.digests_file_path)
    end
    teardown do
      subject.reset
    end

    should have_imeths :init, :digests_file, :reset, :empty?, :[]

    should "be a singleton" do
      assert_includes Singleton, subject.included_modules
    end

    should "know its digests file" do
      digests_file = subject.digests_file

      assert_kind_of Dassets::DigestsFile, digests_file
      assert_not_empty digests_file
      assert_equal digests_file[digests_file.keys.first], subject[digests_file.keys.first]
    end

  end

end
