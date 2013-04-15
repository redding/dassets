require 'digest/md5'

module Dassets; end
class Dassets::AssetFile

  def self.from_abs_path(abs_path)
    path = abs_path.sub("#{Dassets.config.files_path}/", '')
    md5  = Digest::MD5.file(abs_path).hexdigest
    self.new(path, md5)
  end

  attr_reader :path, :md5

  def initialize(path, md5)
    @path, @md5 = path, md5
  end

  def cache_path
    fingerprint = @md5
    dirname     = File.dirname(@path)
    extname     = File.extname(@path)
    basename    = File.basename(@path, extname)

    File.join(dirname, "#{basename}-#{fingerprint}#{extname}")
  end

end
