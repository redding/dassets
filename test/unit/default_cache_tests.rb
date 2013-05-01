require 'assert'
require 'dassets/default_cache'

class Dassets::DefaultCache

  class BaseTests < Assert::Context
    desc "Dassets::DefaultCache"
    setup do
      @cache = Dassets::DefaultCache.new
    end
    subject{ @cache }

    should have_imeths :keys, :[], :[]=

    should "only cache fingerprint keys" do
      subject['some val'] = 'something'
      assert_empty subject.keys
      assert_nil subject['some val']

      subject['a -- fingerprint'] = 'finger'
      assert_includes 'a -- fingerprint', subject.keys
      assert_equal 'finger', subject['a -- fingerprint']
    end

  end

end
