require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class DigestCmdRunTests < Assert::Context
    desc "the DigestCmd"
    setup do
      Dassets.config.output_path = 'public'
      Dassets.reset
      Dassets.init
      Dassets.digest_source_files

      @addfile = 'addfile.txt'
      @addfile_path = File.join(File.join(Dassets.config.source_path, @addfile))
      @rmfile = 'file1.txt'
      @rmfile_path = File.join(File.join(Dassets.config.source_path, @rmfile))
      @rmfilecontents = File.read(@rmfile_path)

      FileUtils.touch @addfile_path
      FileUtils.rm @rmfile_path
    end
    teardown do
      File.open(@rmfile_path,  "w"){ |f| f.write @rmfilecontents }
      FileUtils.rm @addfile_path

      Dassets.reset
      Dassets.init
      Dassets.digest_source_files
      Dassets.config.output_path = nil
    end

    should "update the digests on all source files when run with no given paths" do
      assert_not_file_exists output_path(@addfile)
      assert_file_exists output_path(@rmfile)

      Dassets.digest_source_files
      assert_file_exists output_path(@addfile)
      assert_not_file_exists output_path(@rmfile)
    end

    should "update the digests on a single source file when given its path" do
      assert_not_file_exists output_path(@addfile)

      Dassets.digest_source_files([@addfile_path])
      assert_file_exists output_path(@addfile)
    end

    private

    def output_path(file)
      File.join(Dassets.config.output_path, file)
    end

  end

end
