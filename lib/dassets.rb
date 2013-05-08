require 'pathname'
require 'set'
require 'ns-options'

require 'dassets/version'
require 'dassets/file_store'
require 'dassets/default_cache'
require 'dassets/engine'
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

  # Cmds

  def self.digest_source_files(paths=nil)
    require 'dassets/digest_cmd'
    DigestCmd.new(paths).run
  end

  class Config
    include NsOptions::Proxy

    option :assets_file,   Pathname,  :default => ENV['DASSETS_ASSETS_FILE']
    option :file_store,    FileStore, :default => proc{ NullFileStore.new }

    attr_reader :sources, :engines, :combinations
    attr_accessor :cache

    def initialize
      super
      @sources = []
      @engines = Hash.new{ |h,k| Dassets::NullEngine.new }
      @combinations = Hash.new{ |h,k| [k] } # digest pass-thru if none defined
      @cache = DefaultCache.new
    end

    def source(path, &filter)
      @sources << Source.new(path, &filter)
    end

    def engine(input_ext, engine_class, opts=nil)
      @engines[input_ext.to_s] = engine_class.new(opts)
    end

    def combination(key_digest_path, value_digest_paths)
      @combinations[key_digest_path.to_s] = [*value_digest_paths]
    end
  end

  module SourceList
    def self.new(sources)
      sources.inject([]){ |list, source| list += source.files }
    end
  end

end
