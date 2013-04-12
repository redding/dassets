require 'pathname'
require 'singleton'
require 'ns-options'
require 'multi_json'

require 'dassets/version'
require 'dassets/root_path'

module Dassets

  def self.config; Config; end
  def self.configure(&block); Config.define(&block); end

  def self.init
    Digests.init(self.config.digests_file_path)
  end

  def self.digests; Digests; end

  class Config
    include NsOptions::Proxy

    option :root_path,  Pathname, :required => true
    option :files_path, RootPath, :default => proc{ "app/assets/public" }
    option :digests_file_path, RootPath, :default => proc{ "app/assets/.digests" }

  end

  class Digests
    include Singleton

    def init(file_path)
      @hash = MultiJson.decode(File.read(file_path))
    end

    def reset
      @hash = {}
    end

    # all objs define #hash so need to override it b/c method missing below won't work
    def self.hash; self.instance.hash; end
    def hash; @hash || {}; end

    def empty?; self.hash.empty?; end
    def [](*args); self.hash.send('[]', *args); end

    def reset
      @hash = {}
    end

    # nice singleton api

    def self.method_missing(method, *args, &block)
      self.instance.send(method, *args, &block)
    end

    def self.respond_to?(method)
      super || self.instance.respond_to?(method)
    end

  end

end
