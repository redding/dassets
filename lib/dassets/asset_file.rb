require 'digest/md5'
require 'rack/utils'
require 'rack/mime'

module Dassets; end
class Dassets::AssetFile

  def self.from_abs_path(abs_path)
    rel_path = abs_path.sub("#{Dassets.config.files_path}/", '')
    md5  = Digest::MD5.file(abs_path).hexdigest
    self.new(rel_path, md5)
  end

  attr_reader :path, :md5, :dirname, :extname, :basename
  attr_reader :files_path, :cache_path, :href

  def initialize(rel_path, md5)
    @path, @md5 = rel_path, md5
    @dirname  = File.dirname(@path)
    @extname  = File.extname(@path)
    @basename = File.basename(@path, @extname)

    file_name = "#{@basename}-#{@md5}#{@extname}"
    @files_path = File.join(Dassets.config.files_path, @path)
    @cache_path = File.join(@dirname, file_name).sub(/^\.\//, '').sub(/^\//, '')
    @href = "/#{@cache_path}"
  end

  def content
    @content ||= if File.exists?(@files_path) && File.file?(@files_path)
      File.read(@files_path)
    end
  end

  def mtime
    @mtime ||= if File.exists?(@files_path) && File.file?(@files_path)
      File.mtime(@files_path).httpdate
    end
  end

  # We check via File::size? whether this file provides size info via stat,
  # otherwise we have to figure it out by reading the whole file into memory.
  def size
    @size ||= if File.exists?(@files_path) && File.file?(@files_path)
      File.size?(@files_path) || Rack::Utils.bytesize(self.content)
    end
  end

  def mime_type
    @mime_type ||= if File.exists?(@files_path) && File.file?(@files_path)
      Rack::Mime.mime_type(@extname)
    end
  end

  def exists?
    File.exists?(@files_path) && File.file?(@files_path)
  end

  def ==(other_asset_file)
    other_asset_file.kind_of?(Dassets::AssetFile) &&
    self.path == other_asset_file.path &&
    self.md5 == other_asset_file.md5
  end

end
