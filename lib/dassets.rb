require 'pathname'
require 'singleton'
require 'ns-options'

require 'dassets/version'
require 'dassets/root_path'

module Dassets

  def self.config; Config; end
  def self.configure(&block); Config.define(&block); end

  def self.init
  end

  def self.digests; {}; end

  class Config
    include NsOptions::Proxy

    option :root_path,  Pathname, :required => true
    option :files_path, RootPath, :default => proc{ "app/assets/public" }
    option :digests_file_path, RootPath, :default => proc{ "app/assets/.digests" }

  end

end
