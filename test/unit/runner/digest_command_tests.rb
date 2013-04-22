require 'assert'
require 'fileutils'
require 'dassets/runner/digest_command'

class Dassets::Runner::DigestCommand

  class BaseTests < Assert::Context
    desc "Dassets::Runner::DigestCommand"
    setup do
      @cmd = Dassets::Runner::DigestCommand.new([])
    end
    subject{ @cmd }

    should have_instance_methods :asset_files, :digests_file, :run

    should "know it's digests file" do
      assert_kind_of Dassets::DigestsFile, subject.digests_file
    end

    should "get it's asset files from the config path by default" do
      assert_equal 4, subject.asset_files.size
    end

    should "get it's asset files from the args if passed" do
      path_string = File.join(Dassets.config.files_path, 'file*')
      digest_cmd  = Dassets::Runner::DigestCommand.new([path_string])

      assert_equal 2, digest_cmd.asset_files.size
    end

    should "use AssetFile objs for the asset files" do
      assert_kind_of Dassets::AssetFile, subject.asset_files.first
    end

  end

  class RunTests < BaseTests
    desc "on run"
    setup do
      @cmd.run
      @addfile = 'addfile.txt'
      @rmfile  = 'file1.txt'
      @updfile = 'file2.txt'
      @addfile_path = File.join(File.join(Dassets.config.files_path, @addfile))
      @rmfile_path  = File.join(File.join(Dassets.config.files_path, @rmfile))
      @updfile_path = File.join(File.join(Dassets.config.files_path, @updfile))

      @rmfilecontents   = File.read(@rmfile_path)
      @updfilecontents  = File.read(@updfile_path)
      @orig_updfile_md5 = subject.digests_file[@updfile]

      FileUtils.touch @addfile_path
      FileUtils.rm @rmfile_path
      File.open(@updfile_path, "w+"){ |f| f.write('an update') }
    end
    teardown do
      File.open(@updfile_path, "w"){ |f| f.write @updfilecontents }
      File.open(@rmfile_path,  "w"){ |f| f.write @rmfilecontents }
      FileUtils.rm @addfile_path
    end

    should "update the digests_file on run" do
      assert_equal 4, subject.digests_file.keys.size
      assert_not_includes @addfile, subject.digests_file.keys
      assert_includes @rmfile, subject.digests_file.keys
      assert_equal @orig_updfile_md5, subject.digests_file[@updfile]

      # recreate the cmd to reload asset files
      @cmd = Dassets::Runner::DigestCommand.new([])
      # run without writing the file
      subject.run(false)

      # see the add, update and removal
      assert_equal 4, subject.digests_file.keys.size
      assert_includes @addfile, subject.digests_file.keys
      assert_not_includes @rmfile, subject.digests_file.keys
      assert_not_equal @orig_updfile_md5, subject.digests_file[@updfile]
    end

    should "update the digests_file when run on a single file" do
      assert_equal 4, subject.digests_file.keys.size
      assert_not_includes @addfile, subject.digests_file.keys

      # recreate the cmd to reload asset files
      @cmd = Dassets::Runner::DigestCommand.new([@addfile_path])
      # run without writing the file
      subject.run(false)

      # see the add, don't change anything else
      assert_equal 5, subject.digests_file.keys.size
      assert_includes @addfile, subject.digests_file.keys
      assert_includes @rmfile, subject.digests_file.keys
      assert_equal    @orig_updfile_md5, subject.digests_file[@updfile]
    end

  end

end
