require 'assert'
require 'dassets/config'

require 'dassets/cache'
require 'dassets/file_store'

class Dassets::Config

  class UnitTests < Assert::Context
    desc "Dassets::Config"
    setup do
      @config = Dassets::Config.new
    end
    subject{ @config }

    should have_readers :combinations
    should have_imeths :base_url, :set_base_url
    should have_imeths :file_store, :content_cache, :fingerprint_cache
    should have_imeths :source, :combination, :combination?

    should "have no base url by default" do
      assert_nil subject.base_url
    end

    should "set non-nil base urls" do
      url = Factory.url
      subject.base_url url
      assert_equal url, subject.base_url

      subject.base_url(nil)
      assert_equal url, subject.base_url
    end

    should "force set any base urls" do
      url = Factory.url
      subject.set_base_url url
      assert_equal url, subject.base_url

      subject.set_base_url(nil)
      assert_nil subject.base_url
    end

    should "default the file store option to a null file store" do
      assert_kind_of Dassets::FileStore::NullStore, subject.file_store
    end

    should "configure non-nil file stores" do
      store_root = Factory.path
      subject.file_store(store_root)
      assert_equal store_root, subject.file_store.root

      store = Dassets::FileStore.new(Factory.path)
      subject.file_store(store)
      assert_equal store, subject.file_store

      subject.content_cache(nil)
      assert_equal store, subject.file_store
    end

    should "default its content cache" do
      assert_instance_of Dassets::Cache::NoCache, subject.content_cache
    end

    should "configure non-nil content caches" do
      cache = Dassets::Cache::MemCache.new
      subject.content_cache(cache)
      assert_equal cache, subject.content_cache

      subject.content_cache(nil)
      assert_equal cache, subject.content_cache
    end

    should "default its fingerprint cache" do
      assert_instance_of Dassets::Cache::NoCache, subject.fingerprint_cache
    end

    should "configure non-nil fingerprint caches" do
      cache = Dassets::Cache::MemCache.new
      subject.fingerprint_cache(cache)
      assert_equal cache, subject.fingerprint_cache

      subject.fingerprint_cache(nil)
      assert_equal cache, subject.fingerprint_cache
    end

    should "register new sources with the `source` method" do
      path = '/path/to/app/assets'
      filter = proc{ |paths| [] }
      subject.source(path){ |s| s.filter(&filter) }

      assert_equal 1, subject.sources.size
      assert_kind_of Dassets::Source, subject.sources.first
      assert_equal path, subject.sources.first.path
      assert_equal filter, subject.sources.first.filter
    end

    should "know its combinations and return the keyed digest path by default" do
      assert_kind_of ::Hash, subject.combinations
      assert_equal ['some/digest.path'], subject.combinations['some/digest.path']
    end

    should "allow registering new combinations" do
      assert_equal ['some/digest.path'], subject.combinations['some/digest.path']
      exp_combination = ['some/other.path', 'and/another.path']
      subject.combination 'some/digest.path', exp_combination
      assert_equal exp_combination, subject.combinations['some/digest.path']

      assert_equal ['test/digest.path'], subject.combinations['test/digest.path']
      subject.combination 'test/digest.path', ['some/other.path']
      assert_equal ['some/other.path'], subject.combinations['test/digest.path']
    end

    should "know which digest paths are actual combinations and which are just pass-thrus" do
      subject.combination 'some/combination.path', ['some.path', 'another.path']

      assert     subject.combination? 'some/combination.path'
      assert_not subject.combination? 'some/non-combo.path'
    end

  end

end
