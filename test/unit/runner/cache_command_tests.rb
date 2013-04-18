require 'assert'
require 'fileutils'
require 'dassets/runner/cache_command'

class Dassets::Runner::CacheCommand

  class BaseTests < Assert::Context
    desc "Dassets::Runner::CacheCommand"
    setup do
      @cache_root_path = File.join(Dassets.config.root_path, 'public')
      FileUtils.mkdir_p @cache_root_path
      @cmd = Dassets::Runner::CacheCommand.new(@cache_root_path)
    end
    teardown do
      # FileUtils.rm_rf @cache_root_path
    end
    subject{ @cmd }

    should have_readers :files_root_path, :cache_root_path, :digests_file, :asset_files

    should "use the config's files path and its files root path" do
      assert_equal Dassets.config.files_path, subject.files_root_path.to_s
    end

    should "know its given cache root path" do
      assert_equal @cache_root_path, subject.cache_root_path.to_s
    end

    should "know it's digests file" do
      assert_kind_of Dassets::DigestsFile, subject.digests_file
    end

    should "get it's asset files from the digests file" do
      assert_equal 4, subject.digests_file.keys.size
      assert_equal 4, subject.asset_files.size
    end

    should "use AssetFile objs for the asset files" do
      assert_kind_of Dassets::AssetFile, subject.asset_files.first
    end

  end

  class RunTests < BaseTests
    desc "on run"
    setup do
      FileUtils.rm_rf(@cache_root_path)
    end

    should "create the cache root and write the cache files" do
      assert_not_file_exists @cache_root_path.to_s
      subject.run

      assert_file_exists @cache_root_path.to_s
      subject.asset_files.each do |file|
        assert_file_exists File.join(@cache_root_path, file.cache_path)
      end
    end

  end

end
