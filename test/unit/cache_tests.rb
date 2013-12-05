require 'assert'
require 'dassets/cache'

module Dassets::Cache

  class UnitTests < Assert::Context
    desc "Dassets::Cache"

    should "define an in-memory cache handler" do
      assert MemCache
    end

    should "define a no-op cache handler" do
      assert NoCache
    end

  end

  class MemCacheTests < UnitTests
    desc "MemCache"
    setup do
      @cache = MemCache.new
    end
    subject{ @cache }

    should have_imeths :keys, :[], :[]=

    should "cache given key/value pairs in memory" do
      val = []
      subject['something'] = val
      assert_same val, subject['something']
    end

  end

  class NoCacheTests < UnitTests
    desc "NoCache"
    setup do
      @cache = NoCache.new
    end
    subject{ @cache }

    should have_imeths :keys, :[], :[]=

    should "not cache given key/value pairs in memory" do
      val = []
      subject['something'] = val
      assert_not_same val, subject['something']
    end

  end

end
