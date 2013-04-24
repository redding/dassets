require 'assert'
require 'dassets/engine'
require 'dassets/source_file'

class Dassets::SourceFile

  class BaseTests < Assert::Context
    desc "Dassets::SourceFile"
    setup do
      @config = Dassets::Config.new.tap do |c|
        c.root_path = Dassets.config.root_path
      end

      @file_path = File.join(Dassets.config.root_path, 'app/assets/file1.txt')
      @source_file = Dassets::SourceFile.new(@file_path, @config)
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
      @dumb_engine = Class.new(Dassets::Engine) do
        def ext(in_ext); ''; end
        def compile(input); "#{input}\nDUMB"; end
      end
      @useless_engine = Class.new(Dassets::Engine) do
        def ext(in_ext); 'no-use'; end
        def compile(input); "#{input}\nUSELESS"; end
      end
      @config.engine 'dumb', @dumb_engine
      @config.engine 'useless', @useless_engine

      @file_path = File.join(Dassets.config.root_path, 'app/assets/nested/a-thing.txt.useless.dumb')
      @source_file = Dassets::SourceFile.new(@file_path, @config)
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
