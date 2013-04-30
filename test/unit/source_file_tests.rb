require 'assert'
require 'dassets/asset_file'
require 'dassets/source_file'

class Dassets::SourceFile

  class BaseTests < Assert::Context
    desc "Dassets::SourceFile"
    setup do
      @file_path = File.join(Dassets.config.source_path, 'file1.txt')
      @source_file = Dassets::SourceFile.new(@file_path)
    end
    subject{ @source_file }

    should have_readers :file_path
    should have_imeths :asset_file, :digest_path
    should have_imeths :compiled, :fingerprint, :exists?, :mtime
    should have_cmeth :find_by_digest_path

    should "know its file path" do
      assert_equal @file_path, subject.file_path
    end

    should "know if it exists" do
      assert subject.exists?
    end

    should "use the mtime of its file as its mtime" do
      assert_equal File.mtime(subject.file_path).httpdate, subject.mtime
    end

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "know its asset file" do
      assert_kind_of Dassets::AssetFile, subject.asset_file
      assert_equal Dassets::AssetFile.new(subject.digest_path), subject.asset_file
    end

    should "know its compiled content fingerprint" do
      assert_equal 'daa05c683a4913b268653f7a7e36a5b4', subject.fingerprint
    end

    should "be findable by its digest path" do
      found = Dassets::SourceFile.find_by_digest_path(subject.digest_path)

      assert_equal subject, found
      assert_not_same subject, found
    end

    should "find a null src file if finding by an unknown digest path" do
      null_src = Dassets::NullSourceFile.new('not/found/digest/path')
      found = Dassets::SourceFile.find_by_digest_path('not/found/digest/path')

      assert_equal null_src, found
      assert_not_same null_src, found
    end

  end

  class EngineTests < BaseTests
    desc "compiled against engines"
    setup do
      @file_path = File.join(Dassets.config.source_path, 'nested/a-thing.txt.useless.dumb')
      @source_file = Dassets::SourceFile.new(@file_path)
    end

    should "build the digest path appropriately" do
      assert_equal 'nested/a-thing.txt.no-use', subject.digest_path
    end

    should "compile the source content appropriately" do
      file_content = File.read(@file_path)
      exp_compiled_content = [ file_content, 'DUMB', 'USELESS' ].join("\n")
      assert_equal exp_compiled_content, subject.compiled
    end

  end

end
