require 'pathname'
require 'fileutils'
require 'dassets'
require 'dassets/digests'

module Dassets; end
class Dassets::Cmds; end
class Dassets::Cmds::CacheCmd

  attr_reader :cache_root_path, :digests

  def initialize(cache_root_path)
    @cache_root_path = Pathname.new(cache_root_path)
    @digests = Dassets::Digests.new(Dassets.config.digests_path)
  end

  def run # TODO: pass in io to write to
    @digests.asset_files.each do |file|
      cache_path = @cache_root_path.join(file.url).to_s

      FileUtils.mkdir_p File.dirname(cache_path)
      FileUtils.cp(file.output_path, cache_path)
    end
  end

end
