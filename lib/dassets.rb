require 'pathname'
require 'set'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/asset_file'
require 'dassets/engine'

ENV['DASSETS_ASSETS_FILE'] ||= 'config/assets'

module Dassets

  def self.config;  @config  ||= Config.new; end
  def self.sources; @sources ||= Set.new;    end

  def self.configure(&block)
    block.call(self.config)
  end

  def self.reset
    @sources = nil
  end

  def self.init
    require self.config.assets_file
    @sources = SourceList.new(self.config)
  end

  def self.[](digest_path)
    Dassets::AssetFile.new(digest_path)
  end

  # Cmds

  def self.digest_source_files(paths=nil)
    require 'dassets/digest_cmd'
    DigestCmd.new(paths).run
  end

  class Config
    include NsOptions::Proxy

    option :root_path,    Pathname, :required => true
    option :output_path,  RootPath, :required => true

    option :assets_file,  Pathname, :default => ENV['DASSETS_ASSETS_FILE']
    option :source_path,  RootPath, :default => proc{ "app/assets" }
    option :source_filter, Proc, :default => proc{ |paths| paths }

    attr_reader :engines

    def initialize
      super
      @engines = Hash.new{ |k,v| Dassets::NullEngine.new }
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
      paths.reject!{ |path| path =~ /^#{config.output_path}/ } if config.output_path

      config.source_filter.call(paths).sort
    end
  end

end
