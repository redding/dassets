require 'pathname'
require 'set'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/digests'
require 'dassets/engine'

ENV['DASSETS_ASSETS_FILE'] ||= 'config/assets'

module Dassets

  def self.config; @config ||= Config.new; end
  def self.configure(&block); self.config.define(&block); end

  def self.init
    require self.config.assets_file
    @sources = SourceList.new(self.config)
    @digests = Digests.new(self.config.digests_path)
  end

  def self.reset
    @sources = @digests = nil
  end

  def self.sources; @sources || Set.new;         end
  def self.digests; @digests || NullDigests.new; end

  def self.[](asset_path)
    self.digests.asset_file(asset_path)
  end

  class Config
    include NsOptions::Proxy

    option :root_path,    Pathname, :required => true
    option :digests_path, Pathname, :required => true
    option :output_path,  RootPath, :required => true

    option :assets_file,  Pathname, :default => ENV['DASSETS_ASSETS_FILE']
    option :source_path,  RootPath, :default => proc{ "app/assets" }
    option :source_filter, Proc, :default => proc{ |paths| paths }

    attr_reader :engines

    def initialize
      super({
        :digests_path => proc{ File.join(self.source_path, '.digests') },
        :output_path  => proc{ File.join(self.source_path, 'public')   }
      })
      @engines = Hash.new{ |k,v| Dassets::NullEngine.new }
    end

    def source(path=nil, &filter)
      self.source_path   = path  if path
      self.source_filter = filter if filter
    end

    def engine(input_ext, engine_class, opts=nil)
      @engines[input_ext.to_s] = engine_class.new(opts)
    end

    # deprecated
    option :files_path,  RootPath, :default => proc{ "app/assets/public" }

  end

  class SourceList

    def self.new(config)
      paths = Set.new
      paths += Dir.glob(File.join(config.source_path, "**/*"))
      paths.reject!{ |path| !File.file?(path) }
      paths.reject!{ |path| path =~ /^#{config.output_path}/ }

      config.source_filter.call(paths).sort
    end

  end

end
