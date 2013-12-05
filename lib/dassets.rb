require 'dassets/version'
require 'dassets/asset_file'
require 'dassets/config'

module Dassets

  def self.config; @config ||= Config.new; end
  def self.configure(&block)
    block.call(self.config)
  end

  def self.init
    @asset_files ||= {}
  end

  def self.[](digest_path)
    @asset_files[digest_path] ||= AssetFile.new(digest_path)
  end

  def self.source_list
    SourceList.new(self.config.sources)
  end

  module SourceList
    def self.new(sources)
      sources.inject([]){ |list, source| list += source.files }
    end
  end

end
