require 'assert'
require 'dassets/source_file'

require 'dassets/asset_file'
require 'dassets/source_proxy'

class Dassets::SourceFile

  class UnitTests < Assert::Context
    desc "Dassets::SourceFile"
    setup do
      @file_path = TEST_SUPPORT_PATH.join('app/assets/file1.txt').to_s
      @source_file = Dassets::SourceFile.new(@file_path)
    end
    subject{ @source_file }

    should have_readers :file_path
    should have_imeths :source, :asset_file, :digest_path
    should have_imeths :compiled, :exists?, :mtime
    should have_cmeth :find_by_digest_path

    should "know its file path" do
      assert_equal @file_path.to_s, subject.file_path
    end

    should "know if it exists" do
      assert subject.exists?
    end

    should "use the mtime of its file as its mtime" do
      assert_equal File.mtime(subject.file_path), subject.mtime
    end

    should "know its digest path" do
      assert_equal 'file1.txt', subject.digest_path
    end

    should "know its asset file" do
      assert_kind_of Dassets::AssetFile, subject.asset_file
      assert_equal Dassets::AssetFile.new(subject.digest_path), subject.asset_file
    end

    should "know its configured source" do
      exp_source = Dassets.config.sources.select{ |s| @file_path.include?(s.path) }.last
      assert_equal exp_source, subject.source
    end

    should "be findable by its digest path" do
      found = Dassets::SourceFile.find_by_digest_path(subject.digest_path)

      assert_equal subject, found
      assert_not_same subject, found
    end

    should "not memoize its compiled source" do
      compiled1 = subject.compiled
      compiled2 = subject.compiled
      assert_not_same compiled2, compiled1
    end

  end

  class NullSourceTests < UnitTests

    should "find a null src file if finding by an unknown digest path" do
      null_src = Dassets::NullSourceFile.new('not/found/digest/path')
      found = Dassets::SourceFile.find_by_digest_path('not/found/digest/path')

      assert_equal    null_src, found
      assert_not_same null_src, found

      assert_equal '',    null_src.file_path
      assert_equal false, null_src.exists?
      assert_nil null_src.compiled
      assert_nil null_src.mtime
    end

    should "'proxy' the digest path if the path is a combination" do
      Dassets.config.combination 'file3.txt', ['file1.txt', 'file2.txt']
      src_proxy      = Dassets::SourceProxy.new('file3.txt')
      null_combo_src = Dassets::NullSourceFile.new('file3.txt')

      assert_equal src_proxy.exists?, null_combo_src.exists?
      assert_equal src_proxy.content, null_combo_src.compiled
      assert_equal src_proxy.mtime,   null_combo_src.mtime

      Dassets.config.combinations.delete('file3.txt')
    end

  end

  class EngineTests < UnitTests
    desc "compiled against engines"
    setup do
      @file_path = TEST_SUPPORT_PATH.join('app/assets/nested/a-thing.txt.useless.dumb')
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
