require 'assert'
require 'dassets/root_path'
require 'dassets/file_store'

class Dassets::FileStore

  class BaseTests < Assert::Context
    desc "Dassets::NullFileStore"
    subject{ Dassets::NullFileStore.new }

    should have_reader :root
    should have_imeths :save, :store_path

    should "be a kind of FileStore" do
      assert_kind_of Dassets::FileStore, subject
    end

    should "build its root based on the config's root_path" do
      assert_equal Dassets::RootPath.new(''), subject.root
    end

    should "build the store path based on a given url" do
    end

    should "return the store path on save" do
    end

  end

end
