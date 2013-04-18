require 'pathname'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/digests_file'

ENV['DASSETS_ASSETS_FILE'] ||= 'config/assets'

module Dassets

  def self.config; Config; end
  def self.configure(&block); Config.define(&block); end

  def self.init
    require self.config.assets_file
    @digests_file = DigestsFile.new(self.config.digests_file_path)
  end

  def self.reset
    @digests_file = nil
  end

  def self.digests; @digests_file || NullDigestsFile.new; end
  def self.[](asset_path)
    self.digests.asset_file(asset_path)
  end

  class Config
    include NsOptions::Proxy

    option :assets_file, Pathname, :default => ENV['DASSETS_ASSETS_FILE']
    option :root_path,   Pathname, :required => true
    option :files_path,  RootPath, :default => proc{ "app/assets/public" }
    option :digests_file_path, RootPath, :default => proc{ "app/assets/.digests" }

  end

end
