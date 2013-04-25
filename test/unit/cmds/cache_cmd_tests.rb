require 'assert'
require 'fileutils'
require 'dassets/cmds/cache_cmd'

class Dassets::Cmds::CacheCmd

  class BaseTests < Assert::Context
    desc "Dassets::Cmds::CacheCmd"
    setup do
      @cache_root_path = File.join(Dassets.config.root_path, 'public')
      FileUtils.mkdir_p @cache_root_path
      @cmd = Dassets::Cmds::CacheCmd.new(@cache_root_path)
    end
    subject{ @cmd }

    should have_readers :cache_root_path, :digests

    should "know its given cache root path" do
      assert_equal @cache_root_path, subject.cache_root_path.to_s
    end

    should "know it's digests file" do
      assert_kind_of Dassets::Digests, subject.digests
    end

    should "get it's asset files from the digests file" do
      assert_equal 5, subject.digests.paths.size
      assert_equal 5, subject.digests.asset_files.size
    end

  end

end
