require 'pathname'
require 'singleton'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'
require 'dassets/digests_file'

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
      @digests_file = DigestsFile.new(file_path)
    end

    def digests_file; @digests_file || {}; end
    def reset; @digests_file = nil; end

    def empty?; self.digests_file.empty?; end
    def [](*args); self.digests_file.send('[]', *args); end

    # nice singleton api

    def self.method_missing(method, *args, &block)
      self.instance.send(method, *args, &block)
    end

    def self.respond_to?(method)
      super || self.instance.respond_to?(method)
    end

  end

end
