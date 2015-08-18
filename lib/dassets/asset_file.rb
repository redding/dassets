require 'rack/utils'
require 'rack/mime'
require 'dassets/source_proxy'

module Dassets; end
class Dassets::AssetFile

  attr_reader :digest_path, :dirname, :extname, :basename, :source_proxy

  def initialize(digest_path)
    @digest_path = digest_path
    @dirname  = File.dirname(@digest_path)
    @extname  = File.extname(@digest_path)
    @basename = File.basename(@digest_path, @extname)
    @source_proxy = Dassets::SourceProxy.new(@digest_path, Dassets.config.cache)
  end

  def digest!
    return if !self.exists?
    Dassets.config.file_store.save(self.path){ self.content }
  end

  def path
    path_basename = "#{@basename}-#{self.fingerprint}#{@extname}"
    File.join(@dirname, path_basename).sub(/^\.\//, '').sub(/^\//, '')
  end

  def url
    "#{dassets_base_url}/#{self.path}"
  end

  alias_method :href, :url

  def fingerprint
    return nil if !self.exists?
    @source_proxy.fingerprint
  end

  def content
    return nil if !self.exists?
    @source_proxy.content
  end

  def mtime
    return nil if !self.exists?
    @source_proxy.mtime.httpdate
  end

  def size
    return nil if !self.exists?
    Rack::Utils.bytesize(self.content)
  end

  def mime_type
    return nil if !self.exists?
    Rack::Mime.mime_type(@extname)
  end

  def exists?
    @source_proxy.exists?
  end

  def ==(other_asset_file)
    other_asset_file.kind_of?(Dassets::AssetFile) &&
    self.digest_path == other_asset_file.digest_path &&
    self.fingerprint == other_asset_file.fingerprint
  end

  private

  def dassets_base_url
    Dassets.config.base_url.to_s
  end

end
