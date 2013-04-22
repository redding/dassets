require 'set'
require 'dassets/asset_file'
require 'dassets/digests_file'

module Dassets; end
class Dassets::Runner; end
class Dassets::Runner::DigestCommand

  attr_reader :asset_files, :digests_file

  def initialize(requested_paths)
    @pwd = ENV['PWD']
    @digests_file = Dassets::DigestsFile.new(Dassets.config.digests_path)
    @asset_files = @requested_files = get_asset_files(requested_paths || [])
    if @asset_files.empty?
      @asset_files = @current_files = get_asset_files([*Dassets.config.files_path])
    end
  end

  def run(save=true)
    begin
      prune_digests if @requested_files.empty?
      update_digests(@asset_files)
      @digests_file.save! if save
      unless ENV['DASSETS_TEST_MODE']
        $stdout.puts "digested #{@asset_files.size} assets, saved to #{@digests_file.path}"
      end
      return save
    rescue Exception => e
      unless ENV['DASSETS_TEST_MODE']
        $stderr.puts e, *e.backtrace; $stderr.puts ""
      end
      raise Dassets::Runner::CmdFail
    end
  end

  private

  def update_digests(files)
    files.each{ |f| @digests_file[f.path] = f.md5 }
  end

  def prune_digests
    # prune paths in digests not in current files
    (@digests_file.keys - @current_files.map{ |f| f.path }).each do |file|
      @digests_file.delete(file)
    end
  end

  # Get all file paths fuzzy-matching the given paths.  Each path must be a
  # file that exists and is in the `config.files_path` tree.  Return them
  # as sorted AssetFile objects.
  def get_asset_files(paths)
    fuzzy_paths(paths).
      select{ |p| is_asset_file?(p) }.
      sort.
      map{ |p| Dassets::AssetFile.from_abs_path(p) }
  end

  def fuzzy_paths(paths)
    paths.inject(Set.new) do |paths, path|
      p = File.expand_path(path, @pwd)
      paths += Dir.glob("#{p}*") + Dir.glob("#{p}*/**/*")
    end
  end

  def is_asset_file?(path)
    File.file?(path) && path.include?("#{Dassets.config.files_path}/")
  end

end
