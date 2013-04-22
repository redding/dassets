require 'pathname'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/digests_file'

ENV['DASSETS_ASSETS_FILE'] ||= 'config/assets'

module Dassets

  def self.config; @config ||= Config.new; end
  def self.configure(&block); self.config.define(&block); end

  def self.init
    require self.config.assets_file
    @digests_file = DigestsFile.new(self.config.digests_path)
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

    option :root_path,    Pathname, :required => true
    option :digests_path, Pathname, :required => true

    option :assets_file,  Pathname, :default => ENV['DASSETS_ASSETS_FILE']
    option :source_path,  RootPath, :default => proc{ "app/assets" }
    option :source_filter, Proc, :default => proc{ |paths| paths }

    def initialize
      super({
        :digests_path => proc{ File.join(self.source_path, '.digests') },
        :output_path  => proc{ File.join(self.source_path, 'public')   }
      })
    end

    def sources(path=nil, &block)
      self.source_path   = path  if path
      self.source_filter = block if block
    end

    # deprecated
    option :files_path,  RootPath, :default => proc{ "app/assets/public" }

  end

end
