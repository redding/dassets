require 'digest/md5'
require 'rack/utils'
require 'rack/mime'

module Dassets; end
class Dassets::AssetFile

  def self.from_abs_path(abs_path)
    rel_path = abs_path.sub("#{Dassets.config.output_path}/", '')
    md5  = Digest::MD5.file(abs_path).hexdigest
    self.new(rel_path, md5)
  end

  attr_reader :path, :md5, :dirname, :extname, :basename
  attr_reader :output_path, :url, :href

  def initialize(rel_path, md5)
    @path, @md5 = rel_path, md5
    @dirname  = File.dirname(@path)
    @extname  = File.extname(@path)
    @basename = File.basename(@path, @extname)

    @output_path = File.join(Dassets.config.output_path, @path)

    url_basename = "#{@basename}-#{@md5}#{@extname}"
    @url = File.join(@dirname, url_basename).sub(/^\.\//, '').sub(/^\//, '')
    @href = "/#{@url}"
  end

  def content
    @content ||= if File.exists?(@output_path) && File.file?(@output_path)
      File.read(@output_path)
    end
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
    self.md5 == other_asset_file.md5
  end

end
