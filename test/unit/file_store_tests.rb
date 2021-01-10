# frozen_string_literal: true

require "assert"
require "dassets/file_store"

class Dassets::FileStore
  class UnitTests < Assert::Context
    desc "Dassets::FileStore"
    subject{ Dassets::FileStore.new(@root.to_s) }

    setup do
      @root      = TEST_SUPPORT_PATH.join("public")
      @url_path  = Factory.url
      @root_path = File.join(@root, @url_path).to_s
      FileUtils.rm_f(@root_path)
    end

    teardown do
      FileUtils.rm_rf(@root.to_s)
    end

    should have_readers :root
    should have_imeths :save, :store_path

    should "know its root" do
      assert_that(subject.root).equals(@root.to_s)
    end

    should "build the store path based on a given url path" do
      assert_that(subject.store_path(@url_path)).equals(@root_path)
    end

    should "write a file and return the store path on save" do
      content = Factory.text
      assert_that(@root_path).is_not_a_file

      path = subject.save(@url_path){ content }

      assert_that(path).equals(@root_path)
      assert_that(@root_path).is_a_file
      assert_that(File.read(@root_path)).equals(content)
    end
  end
end

class Dassets::NullFileStore
  class UnitTests < Assert::Context
    desc "Dassets::NullFileStore"
    subject{ Dassets::NullFileStore.new }

    setup do
      @root      = TEST_SUPPORT_PATH.join("public")
      @url_path  = Factory.url
      @root_path = File.join(@root, @url_path).to_s
      FileUtils.rm_f(@root_path)
    end

    teardown do
      FileUtils.rm_rf(@root.to_s)
    end

    should "be a kind of Dassets::FileStore" do
      assert_that(subject).is_kind_of(Dassets::FileStore)
    end

    should "know its root" do
      assert_that(subject.root).equals("")
    end

    should "return the store path on save but not save a file" do
      assert_that(subject.save(@url_path)).equals(File.join("", @url_path))
      assert_that(@root_path).is_not_a_file
    end
  end
end
