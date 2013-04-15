require 'digest/md5'

module Dassets; end
class Dassets::AssetFile

  attr_reader :path

  def initialize(file_path)
    @path = file_path
  end

  def md5
    Digest::MD5.file(@path).hexdigest
  end

end
