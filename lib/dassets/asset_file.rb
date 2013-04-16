require 'digest/md5'

module Dassets; end
class Dassets::AssetFile

  def self.from_abs_path(abs_path)
    rel_path = abs_path.sub("#{Dassets.config.files_path}/", '')
    md5  = Digest::MD5.file(abs_path).hexdigest
    self.new(rel_path, md5)
  end

  attr_reader :path, :md5, :dirname, :extname, :basename
  attr_reader :cache_path, :href

  def initialize(rel_path, md5)
    @path, @md5 = rel_path, md5
    @dirname  = File.dirname(@path)
    @extname  = File.extname(@path)
    @basename = File.basename(@path, @extname)

    file_name = "#{@basename}-#{@md5}#{@extname}"
    @cache_path = File.join(@dirname, file_name).sub(/^\.\//, '').sub(/^\//, '')
    @href = "/#{@cache_path}"
  end

end
