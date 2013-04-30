require 'rack/utils'
require 'rack/mime'
require 'dassets/source_file'

module Dassets; end
class Dassets::AssetFile

  attr_reader :path, :dirname, :extname, :basename, :source_file

  def initialize(digest_path)
    @path = digest_path
    @dirname  = File.dirname(@path)
    @extname  = File.extname(@path)
    @basename = File.basename(@path, @extname)

    @source_file = Dassets::SourceFile.find_by_digest_path(path)
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

  def fingerprint
    @fingerprint ||= @source_file.fingerprint
  end

  def content
    @content ||= @source_file.compiled
  end

  def href
    @href ||= "/#{self.url}"
  end

  def mtime
    return nil if !self.exists?
    @mtime ||= @source_file.mtime
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
    @source_file.exists?
  end

  def ==(other_asset_file)
    other_asset_file.kind_of?(Dassets::AssetFile) &&
    self.path == other_asset_file.path &&
    self.fingerprint == other_asset_file.fingerprint
  end

end
