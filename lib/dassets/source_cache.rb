require 'dassets/source_file'

module Dassets; end
class Dassets::SourceCache

  attr_reader :digest_path, :source_file

  def initialize(digest_path)
    @digest_path = digest_path
    @source_file = Dassets::SourceFile.find_by_digest_path(digest_path)
  end

  def content
    @source_file.compiled
  end

  def fingerprint
    @source_file.fingerprint
  end

  def key
    "#{self.digest_path} -- #{self.mtime}"
  end

  def mtime
    @source_file.mtime
  end

  def exists?
    @source_file.exists?
  end

end
