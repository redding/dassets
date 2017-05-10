require 'dassets/version'
require 'dassets/asset_file'
require 'dassets/config'
require 'dassets/source_file'

module Dassets

  def self.config; @config ||= Config.new; end
  def self.configure(&block)
    block.call(self.config)
  end

  def self.init
    @asset_files  ||= {}
    @source_files   = SourceFiles.new(self.config.sources)
  end

  def self.reset
    @asset_files = {}
    self.config.reset
  end

  def self.[](digest_path)
    @asset_files[digest_path] ||= AssetFile.new(digest_path)
  end

  def self.source_files
    @source_files
  end

  module SourceFiles

    def self.new(sources)
      # use a hash to store the source files so in the case two source files
      # have the same digest path, the last one *should* be correct since it
      # was last to be configured
      sources.inject({}) do |hash, source|
        source.files.each do |file_path|
          s = SourceFile.new(file_path)
          hash[s.digest_path] = s
        end
        hash
      end
    end

  end

end

Dassets.init
