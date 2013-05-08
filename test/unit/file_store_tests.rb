require 'assert'
require 'dassets/file_store'

class Dassets::FileStore

  class NullTests < Assert::Context
    desc "Dassets::NullFileStore"
    subject{ Dassets::NullFileStore.new }

    should have_reader :root
    should have_imeths :save, :store_path

    should "be a kind of FileStore" do
      assert_kind_of Dassets::FileStore, subject
    end

    should "know its root path" do
      assert_equal '', subject.root
    end

    should "build the store path based on a given url" do
      assert_equal '/some/url', subject.store_path('some/url')
    end

    should "return the store path on save" do
      assert_equal '/some/url', subject.save('some/url')
    end

  end

end
