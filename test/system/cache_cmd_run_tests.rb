require 'assert'
require 'fileutils'
require 'dassets'

module Dassets

  class CacheCmdRunTests < Assert::Context
    desc "the CacheCmd"
    setup do
      @cache_root_path = File.join(Dassets.config.root_path, 'public')
      FileUtils.rm_rf(@cache_root_path)
    end

    should "create the cache root and write the cache files" do
      assert_not_file_exists @cache_root_path.to_s
      cmd = Dassets::Cmds::CacheCmd.new(@cache_root_path)
      cmd.run

      assert_file_exists @cache_root_path.to_s
      cmd.digests.asset_files.each do |file|
        assert_file_exists File.join(@cache_root_path, file.url)
      end
    end

  end

end
