require "assert"
require "dassets/cache"

class Dassets::MemCache
  class UnitTests < Assert::Context
    desc "Dassets::MemCache"
    subject { Dassets::MemCache.new }

    should have_imeths :keys, :[], :[]=

    should "cache given key/value pairs in memory" do
      val = []
      subject["something"] = val
      assert_that(subject["something"]).is(val)
    end
  end
end

class Dassets::NoCache
  class UnitTests < Assert::Context
    desc "Dassets::NoCache"
    subject { Dassets::NoCache.new }

    should have_imeths :keys, :[], :[]=

    should "not cache given key/value pairs in memory" do
      val = []
      subject["something"] = val
      assert_that(subject["something"]).is_not(val)
    end
  end
end
