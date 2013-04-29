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
      @addfile_src = source_path(@addfile)

      @rmfile = 'file1.txt'
      @rmfile_src = source_path(@rmfile)
      @rmfile_contents = File.read(@rmfile_src)

      FileUtils.touch @addfile_src
      @addfile_out = output_path(@addfile)

      @rmfile_out = output_path(@rmfile)
      FileUtils.rm @rmfile_src
    end
    teardown do
      File.open(@rmfile_src,  "w"){ |f| f.write @rmfile_contents }
      FileUtils.rm @addfile_src

      Dassets.reset
      Dassets.init
      Dassets.digest_source_files
      Dassets.config.output_path = nil
    end

    should "update the digests on all source files when run with no given paths" do
      assert_not_file_exists @addfile_out
      assert_file_exists @rmfile_out

      Dassets.digest_source_files
      assert_file_exists @addfile_out
      assert_not_file_exists @rmfile_out
    end

    should "update the digests on a single source file when given its path" do
      assert_not_file_exists @addfile_out

      Dassets.digest_source_files([@addfile_src])
      assert_file_exists @addfile_out
    end

    private

    def source_path(file)
      File.join(File.join(Dassets.config.source_path, file))
    end

    def output_path(file)
      File.join(Dassets.config.output_path, Dassets::AssetFile.new(file).url)
    end

  end

end
