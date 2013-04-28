require 'rack/utils'
require 'rack/mime'
require 'dassets/source_file'

module Dassets; end
class Dassets::AssetFile

  attr_reader :path, :dirname, :extname, :basename, :output_path

  def initialize(digest_path, fingerprint=nil)
    @path, @fingerprint = digest_path, fingerprint
    @dirname  = File.dirname(@path)
    @extname  = File.extname(@path)
    @basename = File.basename(@path, @extname)
    @output_path = File.join(Dassets.config.output_path, @path)
  end

  def source_file
    @source_file ||= Dassets::SourceFile.find_by_digest_path(path)
  end

  def fingerprint
    @fingerprint ||= self.source_file.fingerprint
  end

  def content
    @content ||= if File.exists?(@output_path) && File.file?(@output_path)
      File.read(@output_path)
    else
      self.source_file.compiled
    end
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

  def mtime
    @mtime ||= if File.exists?(@output_path) && File.file?(@output_path)
      File.mtime(@output_path).httpdate
    end
  end

  # We check via File::size? whether this file provides size info via stat,
  # otherwise we have to figure it out by reading the whole file into memory.
  def size
    @size ||= if File.exists?(@output_path) && File.file?(@output_path)
      File.size?(@output_path) || Rack::Utils.bytesize(self.content)
    end
  end

  def mime_type
    @mime_type ||= if File.exists?(@output_path) && File.file?(@output_path)
      Rack::Mime.mime_type(@extname)
    end
  end

  def exists?
    File.exists?(@output_path) && File.file?(@output_path)
  end

  def ==(other_asset_file)
    other_asset_file.kind_of?(Dassets::AssetFile) &&
    self.path == other_asset_file.path &&
    self.fingerprint == other_asset_file.fingerprint
  end

end
