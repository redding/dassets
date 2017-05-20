require 'assert'
require 'dassets/file_store'

class Dassets::FileStore

  class UnitTests < Assert::Context
    desc "Dassets::FileStore"
    setup do
      @root      = TEST_SUPPORT_PATH.join('public')
      @url_path  = Factory.url
      @root_path = File.join(@root, @url_path).to_s
      FileUtils.rm_f(@root_path)

      @store = Dassets::FileStore.new(@root.to_s)
    end
    teardown do
      FileUtils.rm_f(@root_path)
    end
    subject{ @store }

    should have_readers :root
    should have_imeths :save, :store_path

    should "know its root" do
      assert_equal @root.to_s, subject.root
    end

    should "build the store path based on a given url path" do
      assert_equal @root_path, subject.store_path(@url_path)
    end

    should "write a file and return the store path on save" do
      content = Factory.text
      assert_not_file_exists @root_path
      path = subject.save(@url_path){ content }

      assert_equal @root_path, path
      assert_file_exists @root_path
      assert_equal content, File.read(@root_path)
    end

  end

  class NullStoreTests < UnitTests
    desc "NullStore"
    setup do
      @store = Dassets::FileStore::NullStore.new
    end

    should "be a kind of FileStore" do
      assert_kind_of Dassets::FileStore, subject
    end

    should "know its root" do
      assert_equal '', subject.root
    end

    should "return the store path on save but not save a file" do
      assert_equal File.join('', @url_path), subject.save(@url_path)
      assert_not_file_exists @root_path
    end

  end

end
