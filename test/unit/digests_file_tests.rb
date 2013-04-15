require 'assert'
require 'fileutils'
require 'dassets/digests_file'

class Dassets::DigestsFile

  class BaseTests < Assert::Context
    desc "Dassets::DigestsFile"
    setup do
      @file_path = File.join(ROOT_PATH, 'test/support/digests.json')
      @digests = Dassets::DigestsFile.new(@file_path)
    end
    subject{ @digests }

    should have_imeths :path, :to_hash, :save!
    should have_imeths :[], :[]=, :delete, :keys, :values, :empty?

    should "know its path" do
      assert_equal @file_path, subject.path
    end

    should "know whether it is empty or not" do
      assert_not_empty subject
    end

    should "read values with the index operator" do
      assert_equal 'abc123', subject['/path/to/file1']
    end

    should "write values with the index operator" do
      subject['/path/to/test'] = 'testytest'
      assert_equal 'testytest', subject['/path/to/test']
    end

    should "remove values with the delete method" do
      assert_includes '/path/to/file1', subject.keys

      subject.delete '/path/to/file1'
      assert_not_includes '/path/to/file1', subject.keys
    end

    should "know its hash representation" do
      exp_hash = {
        "/path/to/file1" => "abc123",
        "/path/to/file2" => "123abc",
        "/path/to/file3" => "a1b2c3"
      }
      subject_to_hash = subject.to_hash
      subject_internal_hash = subject.instance_variable_get("@hash")

      assert_equal exp_hash, subject_to_hash
      assert_not_equal subject_internal_hash.object_id, subject_to_hash.object_id
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

    should "write out the digests to the path" do
      assert_not_file_exists subject.path
      subject.save!

      assert_file_exists subject.path
    end

  end

end
