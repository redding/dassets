require 'digest/md5'

module Dassets; end
class Dassets::AssetFile

  def initialize(absolute_path, relative_to_path)
    @absolute_path = absolute_path
    @relative_to_path = relative_to_path
  end

  def md5
    Digest::MD5.file(@absolute_path).hexdigest
  end

  def path
    @absolute_path.sub(@relative_to_path, '')
  end

end
