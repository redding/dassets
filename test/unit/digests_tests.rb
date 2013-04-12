require 'assert'
require 'dassets'

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

    should have_imeths :init, :reset, :hash, :empty?, :[]

    should "be a singleton" do
      assert_includes Singleton, subject.included_modules
    end

    should "know its full hash" do
      digests_hash = subject.hash

      assert_kind_of Hash, digests_hash
      assert_not_empty digests_hash
      assert_equal digests_hash[digests_hash.keys.first], subject[digests_hash.keys.first]
    end

  end

end
