require 'pathname'
require 'set'
require 'ns-options'

require 'dassets/version'
require 'dassets/file_store'
require 'dassets/default_cache'
require 'dassets/source'
require 'dassets/asset_file'

ENV['DASSETS_ASSETS_FILE'] ||= 'config/assets'

module Dassets

  def self.config;  @config  ||= Config.new; end
  def self.configure(&block)
    block.call(self.config)
  end

  def self.init
    begin
      require self.config.assets_file
    rescue LoadError
    end
  end

  def self.[](digest_path)
    AssetFile.new(digest_path)
  end

  def self.source_list
    SourceList.new(self.config.sources)
  end

  class Config
    include NsOptions::Proxy

    option :assets_file,   Pathname,  :default => ENV['DASSETS_ASSETS_FILE']
    option :file_store,    FileStore, :default => proc{ NullFileStore.new }

    attr_reader :sources, :combinations
    attr_accessor :cache

    def initialize
      super
      @sources = []
      @combinations = Hash.new{ |h, k| [k] } # digest pass-thru if none defined
      @cache = DefaultCache.new
    end

    def source(path, &block)
      @sources << Source.new(path).tap{ |s| block.call(s) if block }
    end

    def combination(key_digest_path, value_digest_paths)
      @combinations[key_digest_path.to_s] = [*value_digest_paths]
    end

    def combination?(key_digest_path)
      # a digest path is only considered a combination is it is not the default
      # pass-thru above
      @combinations[key_digest_path.to_s] != [key_digest_path]
    end
  end

  module SourceList
    def self.new(sources)
      sources.inject([]){ |list, source| list += source.files }
    end
  end

end
