require 'pathname'
require 'fileutils'
require 'dassets/asset_file'
require 'dassets/digests_file'

module Dassets; end
class Dassets::Runner; end
class Dassets::Runner::CacheCommand

  attr_reader :files_root_path, :cache_root_path, :digests_file, :asset_files

  def initialize(cache_root_path)
    unless cache_root_path && File.directory?(cache_root_path)
      raise Dassets::Runner::CmdError, "specify an existing cache directory"
    end

    @files_root_path = Pathname.new(Dassets.config.files_path)
    @cache_root_path = Pathname.new(cache_root_path)
    @digests_file = Dassets::DigestsFile.new(Dassets.config.digests_file_path)
    @asset_files = @digests_file.asset_files
  end

  def run(write_files=true)
    begin
      @asset_files.each do |file|
        files_path = @files_root_path.join(file.path).to_s
        cache_path = @cache_root_path.join(file.cache_path).to_s

        if write_files
          FileUtils.mkdir_p File.dirname(cache_path)
          FileUtils.cp(files_path, cache_path)
        end
      end
      unless ENV['DASSETS_TEST_MODE']
        $stdout.puts "#{@asset_files.size} files written to #{@cache_root_path}"
      end
      return write_files
    rescue Exception => e
      unless ENV['DASSETS_TEST_MODE']
        $stderr.puts e, *e.backtrace; $stderr.puts ""
      end
      raise Dassets::Runner::CmdFail
    end
  end

end
