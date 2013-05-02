require 'rack/utils'
require 'rack/mime'
require 'dassets/source_cache'

module Dassets; end
class Dassets::AssetFile

  attr_reader :digest_path, :dirname, :extname, :basename, :source_cache

  def initialize(digest_path)
    @digest_path = digest_path
    @dirname  = File.dirname(@digest_path)
    @extname  = File.extname(@digest_path)
    @basename = File.basename(@digest_path, @extname)
    @source_cache = Dassets::SourceCache.new(@digest_path, Dassets.config.cache)
  end

  def digest!
    return if !self.exists?
    Dassets.config.file_store.save(self.url){ self.content }
  end

  def url
    @url ||= begin
      url_basename = "#{@basename}-#{self.fingerprint}#{@extname}"
      File.join(@dirname, url_basename).sub(/^\.\//, '').sub(/^\//, '')
    end
  end

  def href
    @href ||= "/#{self.url}"
  end

  def fingerprint
    return nil if !self.exists?
    @fingerprint ||= @source_cache.fingerprint
  end

  def content
    return nil if !self.exists?
    @content ||= @source_cache.content
  end

  def mtime
    return nil if !self.exists?
    @mtime ||= @source_cache.mtime.httpdate
  end

  def size
    return nil if !self.exists?
    @size ||= Rack::Utils.bytesize(self.content)
  end

  def mime_type
    return nil if !self.exists?
    @mime_type ||= Rack::Mime.mime_type(@extname)
  end

  def exists?
    @source_cache.exists?
  end

  def ==(other_asset_file)
    other_asset_file.kind_of?(Dassets::AssetFile) &&
    self.digest_path == other_asset_file.digest_path &&
    self.fingerprint == other_asset_file.fingerprint
  end

end
