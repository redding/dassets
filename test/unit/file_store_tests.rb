require 'assert'
require 'dassets/file_store'

class Dassets::FileStore

  class UnitTests < Assert::Context
    desc "Dassets::FileStore"
    setup do
      @root = TEST_SUPPORT_PATH.join('public')
      @url = 'some/url'
      @url_path = @root.join(@url).to_s
      FileUtils.rm_f(@url_path)

      @store = Dassets::FileStore.new(@root.to_s)
    end
    teardown do
      FileUtils.rm_f(@url_path)
    end
    subject{ @store }

    should have_readers :root
    should have_imeths :save, :store_path

    should "know its root path" do
      assert_equal @root.to_s, subject.root
    end

    should "build the store path based on a given url" do
      assert_equal @url_path, subject.store_path(@url)
    end

    should "return write a file and return the store path on save" do
      assert_not_file_exists @url_path
      path = subject.save(@url){ 'some contents' }

      assert_equal @url_path, path
      assert_file_exists @url_path
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

    should "know its root path" do
      assert_equal '', subject.root
    end

    should "return the store path on save" do
      assert_equal "/#{@url}", subject.save(@url)
    end

  end

end
