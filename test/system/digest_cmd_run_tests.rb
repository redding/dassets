require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class DigestCmdRunTests < Assert::Context
    desc "the DigestCmd"
    setup do
      Dassets.init
      Dassets::Cmds::DigestCmd.for([]).run

      @addfile = 'addfile.txt'
      @rmfile  = 'file1.txt'
      @updfile = 'file2.txt'
      @addfile_path = File.join(File.join(Dassets.config.source_path, @addfile))
      @rmfile_path  = File.join(File.join(Dassets.config.source_path, @rmfile))
      @updfile_path = File.join(File.join(Dassets.config.source_path, @updfile))

      @rmfilecontents   = File.read(@rmfile_path)
      @updfilecontents  = File.read(@updfile_path)
      @orig_updfile_md5 = Dassets.digests[@updfile]

      FileUtils.touch @addfile_path
      FileUtils.rm @rmfile_path
      File.open(@updfile_path, "w+"){ |f| f.write('an update') }
    end
    teardown do
      File.open(@updfile_path, "w"){ |f| f.write @updfilecontents }
      File.open(@rmfile_path,  "w"){ |f| f.write @rmfilecontents }
      FileUtils.rm @addfile_path

      Dassets::Cmds::DigestCmd.for([]).run
      Dassets.reset
    end

    should "update the digests when run on all source files" do
      # check before state
      assert_equal 5, Dassets.digests.paths.size
      assert_not_includes @addfile, Dassets.digests.paths
      assert_includes @rmfile, Dassets.digests.paths
      assert_equal @orig_updfile_md5, Dassets.digests[@updfile]

      Dassets::Cmds::DigestCmd.for([]).run

      # see the add, update and removal
      assert_equal 5, Dassets.digests.paths.size
      assert_includes @addfile, Dassets.digests.paths
      assert_not_includes @rmfile, Dassets.digests.paths
      assert_not_equal @orig_updfile_md5, Dassets.digests[@updfile]
    end

    should "update the digests when run on a single source file" do
      assert_equal 5, Dassets.digests.paths.size
      assert_not_includes @addfile, Dassets.digests.paths

      Dassets::Cmds::DigestCmd.new([@addfile_path]).run

      # see the add, don't change anything else
      assert_equal 6, Dassets.digests.paths.size
      assert_includes @addfile, Dassets.digests.paths
      assert_includes @rmfile, Dassets.digests.paths
      assert_equal    @orig_updfile_md5, Dassets.digests[@updfile]
    end

  end

end
