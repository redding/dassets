require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class DigestCmdRunTests < Assert::Context
    desc "the DigestCmd"
    setup do
      Dassets.reset
      Dassets.init
      Dassets.digest_source_files

      @addfile = 'addfile.txt'
      @rmfile  = 'file1.txt'
      @updfile = 'file2.txt'
      @addfile_path = File.join(File.join(Dassets.config.source_path, @addfile))
      @rmfile_path  = File.join(File.join(Dassets.config.source_path, @rmfile))
      @updfile_path = File.join(File.join(Dassets.config.source_path, @updfile))

      @rmfilecontents   = File.read(@rmfile_path)
      @updfilecontents  = File.read(@updfile_path)
      @orig_updfile_fprint = Dassets.digests[@updfile]

      FileUtils.touch @addfile_path
      FileUtils.rm @rmfile_path
      File.open(@updfile_path, "w+"){ |f| f.write('an update') }
    end
    teardown do
      File.open(@updfile_path, "w"){ |f| f.write @updfilecontents }
      File.open(@rmfile_path,  "w"){ |f| f.write @rmfilecontents }
      FileUtils.rm @addfile_path

      Dassets.reset
      Dassets.init
      Dassets.digest_source_files
    end

    should "update the digests on all source files when run with no given paths" do
      # check before state
      assert_equal 5, Dassets.digests.paths.size
      assert_not_includes @addfile, Dassets.digests.paths
      assert_includes @rmfile, Dassets.digests.paths
      assert_equal @orig_updfile_fprint, Dassets.digests[@updfile]

      Dassets.digest_source_files

      # see the add, update and removal
      assert_equal 5, Dassets.digests.paths.size
      assert_includes @addfile, Dassets.digests.paths
      assert_not_includes @rmfile, Dassets.digests.paths
      assert_not_equal @orig_updfile_fprint, Dassets.digests[@updfile]
    end

    should "update the digests on a single source file when given its path" do
      assert_equal 5, Dassets.digests.paths.size
      assert_not_includes @addfile, Dassets.digests.paths

      Dassets.digest_source_files([@addfile_path])

      # see the add, don't change anything else
      assert_equal 6, Dassets.digests.paths.size
      assert_includes @addfile, Dassets.digests.paths
      assert_includes @rmfile, Dassets.digests.paths
      assert_equal    @orig_updfile_fprint, Dassets.digests[@updfile]
    end

  end

end
