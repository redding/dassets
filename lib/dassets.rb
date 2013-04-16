require 'pathname'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/digests_file'

module Dassets

  def self.config; Config; end
  def self.configure(&block); Config.define(&block); end

  def self.init
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

    option :root_path,  Pathname, :required => true
    option :files_path, RootPath, :default => proc{ "app/assets/public" }
    option :digests_file_path, RootPath, :default => proc{ "app/assets/.digests" }

  end

end
