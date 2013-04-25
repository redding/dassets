require 'assert'
require 'fileutils'
require 'dassets/digests'
require 'dassets/asset_file'

class Dassets::Digests

  class BaseTests < Assert::Context
    desc "Dassets::Digests"
    setup do
      @file_path = File.join(Dassets.config.root_path, 'example.digests')
      @digests = Dassets::Digests.new(@file_path)
    end
    subject{ @digests }

    should have_reader :file_path
    should have_imeths :[], :[]=, :delete, :clear
    should have_imeths :paths, :asset_files, :asset_file, :save!

    should "know its file path" do
      assert_equal @file_path, subject.file_path
    end

    should "know its asset files" do
      assert_equal subject.paths.size, subject.asset_files.size
      assert_kind_of Dassets::AssetFile, subject.asset_files.first
    end

    should "get a specific asset file from its data" do
      file = subject.asset_file('path/to/file1')

      assert_kind_of Dassets::AssetFile, file
      assert_equal 'path/to/file1', file.path
      assert_equal subject['path/to/file1'], file.md5
    end

    should "read values with the index operator" do
      assert_equal 'abc123', subject['path/to/file1']
    end

    should "write values with the index operator" do
      subject['path/to/test'] = 'testytest'
      assert_equal 'testytest', subject['path/to/test']
    end

    should "remove values with the delete method" do
      assert_includes 'path/to/file1', subject.paths

      subject.delete 'path/to/file1'
      assert_not_includes 'path/to/file1', subject.paths
    end

    should "clear values with the clear method" do
      assert_not_empty subject.paths
      subject.clear
      assert_empty subject.paths
    end

  end

  class SaveTests < BaseTests
    desc "on save"
    setup do
      FileUtils.mv(@file_path, "#{@file_path}.bak")
    end
    teardown do
      FileUtils.mv("#{@file_path}.bak", @file_path)
    end

    should "write out the digests to the file path" do
      assert_not_file_exists subject.file_path
      subject.save!

      assert_file_exists subject.file_path
    end

  end

end
