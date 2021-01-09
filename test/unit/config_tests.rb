# frozen_string_literal: true

require "assert"
require "dassets/config"

require "dassets/cache"
require "dassets/file_store"

class Dassets::Config
  class UnitTests < Assert::Context
    desc "Dassets::Config"
    subject{ @config }

    setup do
      @config = Dassets::Config.new
    end

    should have_readers :combinations
    should have_imeths :reset
    should have_imeths :base_url, :set_base_url
    should have_imeths :file_store, :content_cache, :fingerprint_cache
    should have_imeths :source, :combination, :combination?

    should "reset its sources and combination on `reset`" do
      assert_that(subject.sources).is_empty
      assert_that(subject.combinations).is_empty

      path = Factory.path
      subject.source(path)
      subject.combination path, [Factory.path]
      assert_that(subject.sources.size).equals(1)
      assert_that(subject.combinations.size).equals(1)

      subject.reset
      assert_that(subject.sources).is_empty
      assert_that(subject.combinations).is_empty
    end

    should "have no base url by default" do
      assert_that(subject.base_url).is_nil
    end

    should "set non-nil base urls" do
      url = Factory.url
      subject.base_url url
      assert_that(subject.base_url).equals(url)

      subject.base_url(nil)
      assert_that(subject.base_url).equals(url)
    end

    should "force set any base urls" do
      url = Factory.url
      subject.set_base_url url
      assert_that(subject.base_url).equals(url)

      subject.set_base_url(nil)
      assert_that(subject.base_url).is_nil
    end

    should "default the file store option to a null file store" do
      assert_that(subject.file_store).is_kind_of(Dassets::NullFileStore)
    end

    should "configure non-nil file stores" do
      store_root = Factory.path
      subject.file_store(store_root)
      assert_that(subject.file_store.root).equals(store_root)

      store = Dassets::FileStore.new(Factory.path)
      subject.file_store(store)
      assert_that(subject.file_store).equals(store)

      subject.file_store(nil)
      assert_that(subject.file_store).equals(store)
    end

    should "default its content cache" do
      assert_that(subject.content_cache).is_instance_of(Dassets::NoCache)
    end

    should "configure non-nil content caches" do
      cache = Dassets::MemCache.new
      subject.content_cache(cache)
      assert_that(subject.content_cache).equals(cache)

      subject.content_cache(nil)
      assert_that(subject.content_cache).equals(cache)
    end

    should "default its fingerprint cache" do
      assert_instance_of Dassets::NoCache, subject.fingerprint_cache
    end

    should "configure non-nil fingerprint caches" do
      cache = Dassets::MemCache.new
      subject.fingerprint_cache(cache)
      assert_that(subject.fingerprint_cache).equals(cache)

      subject.fingerprint_cache(nil)
      assert_that(subject.fingerprint_cache).equals(cache)
    end

    should "register new sources with the `source` method" do
      path = Factory.path
      filter = proc{ |_paths| [] }
      subject.source(path){ |s| s.filter(&filter) }

      assert_that(subject.sources.size).equals(1)
      assert_that(subject.sources.first).is_kind_of(Dassets::Source)
      assert_that(subject.sources.first.path).equals(path)
      assert_that(subject.sources.first.filter).equals(filter)
    end

    should "know its combinations and return the keyed digest path by "\
           "default" do
      assert_that(subject.combinations).is_kind_of(::Hash)
      assert_that(subject.combinations["some/digest.path"])
        .equals(["some/digest.path"])
    end

    should "allow registering new combinations" do
      assert_that(subject.combinations["some/digest.path"])
        .equals(["some/digest.path"])
      exp_combination = ["some/other.path", "and/another.path"]
      subject.combination "some/digest.path", exp_combination
      assert_that(subject.combinations["some/digest.path"])
        .equals(exp_combination)

      assert_that(subject.combinations["test/digest.path"])
        .equals(["test/digest.path"])
      subject.combination "test/digest.path", ["some/other.path"]
      assert_that(subject.combinations["test/digest.path"])
        .equals(["some/other.path"])
    end

    should "know which digest paths are actual combinations and which are "\
           "just pass-thrus" do
      subject.combination "some/combination.path", ["some.path", "another.path"]

      assert_that(subject.combination?("some/combination.path")).is_true
      assert_that(subject.combination?("some/non-combo.path")).is_false
    end
  end
end
