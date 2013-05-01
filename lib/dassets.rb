require 'pathname'
require 'set'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/file_store'
require 'dassets/default_cache'
require 'dassets/engine'
require 'dassets/asset_file'

ENV['DASSETS_ASSETS_FILE'] ||= 'config/assets'

module Dassets

  def self.config;  @config  ||= Config.new; end
  def self.configure(&block)
    block.call(self.config)
  end

  def self.init
    require self.config.assets_file
  end

  def self.[](digest_path)
    AssetFile.new(digest_path)
  end

  # Cmds

  def self.digest_source_files(paths=nil)
    require 'dassets/digest_cmd'
    DigestCmd.new(paths).run
  end

  class Config
    include NsOptions::Proxy

    option :root_path,     Pathname,  :required => true
    option :assets_file,   Pathname,  :default => ENV['DASSETS_ASSETS_FILE']
    option :source_path,   RootPath,  :default => proc{ "app/assets" }
    option :source_filter, Proc,      :default => proc{ |paths| paths }
    option :file_store,    FileStore, :default => proc{ NullFileStore.new }

    attr_reader :engines
    attr_accessor :cache

    def initialize
      super
      @engines = Hash.new{ |k,v| Dassets::NullEngine.new }
      @cache = DefaultCache.new
    end

    def source(path=nil, &filter)
      self.source_path   = path  if path
      self.source_filter = filter if filter
    end

    def engine(input_ext, engine_class, opts=nil)
      @engines[input_ext.to_s] = engine_class.new(opts)
    end
  end

  module SourceList
    def self.new(config)
      paths = Set.new
      paths += Dir.glob(File.join(config.source_path, "**/*"))
      paths.reject!{ |path| !File.file?(path) }

      config.source_filter.call(paths).sort
    end
  end

end
