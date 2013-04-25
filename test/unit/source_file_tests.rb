require 'assert'
require 'dassets/engine'
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
    should have_imeths :exists?, :digest_path, :compiled, :fingerprint

    should "know its file path" do
      assert_equal @file_path, subject.file_path
    end

    should "know if it exists" do
      assert subject.exists?
    end

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "know its compiled content fingerprint" do
      assert_equal 'daa05c683a4913b268653f7a7e36a5b4', subject.fingerprint
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

  class DigestTests < EngineTests
    desc "being digested"
    setup do
      Dassets.init
      @digested_asset_file = @source_file.digest
    end
    teardown do
      Dassets.digests.delete(@source_file.digest_path)
      Dassets.digests.save!
      FileUtils.rm @digested_asset_file.output_path
      Dassets.reset
    end

    should "return the digested asset file" do
      assert_not_nil @digested_asset_file
      assert_kind_of Dassets::AssetFile, @digested_asset_file
    end

    should "compile and write an asset file to the output path" do
      assert_file_exists @digested_asset_file.output_path
      assert_equal subject.compiled, File.read(@digested_asset_file.output_path)
    end

    should "add a digests entry for the asset file with its fingerprint" do
      digests_on_disk = Dassets::Digests.new(Dassets.config.digests_path)
      assert_equal subject.fingerprint, digests_on_disk[subject.digest_path]
    end

  end

end
