require 'set'
require 'dassets/asset_file'
require 'dassets/digests_file'

module Dassets; end
class Dassets::Runner; end
class Dassets::Runner::DigestCommand

  attr_reader :asset_files, :digests_file

  def initialize(file_paths)
    @asset_files = if (file_paths || []).empty?
      get_asset_files([*Dassets.config.files_path])
    else
      get_asset_files(file_paths)
    end
    @digests_file = Dassets::DigestsFile.new(Dassets.config.digests_file_path)
  end

  def run(save=true)
    begin
      digest_paths = @digests_file.keys
      asset_paths  = @asset_files.map{ |f| f.path }

      (digest_paths - asset_paths).each{ |file| @digests_file.delete(file) }
      @asset_files.each{ |f| @digests_file[f.path] = f.md5 }

      @digests_file.save! if save
      return save
    rescue Exception => e
      $stderr.puts e, *e.backtrace
      $stderr.puts ""
      raise Dassets::Runner::CmdFail
    end
  end

  private

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
      p = File.expand_path(path, Dir.pwd)
      paths += Dir.glob("#{p}*") + Dir.glob("#{p}*/**/*")
    end
  end

  def is_asset_file?(path)
    File.file?(path) && path.include?("#{Dassets.config.files_path}/")
  end

end
