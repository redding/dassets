require 'dassets/source_file'

module Dassets; end
class Dassets::SourceCache

  attr_reader :digest_path, :source_file, :cache

  def initialize(digest_path, cache=nil)
    @digest_path = digest_path
    @source_file = Dassets::SourceFile.find_by_digest_path(digest_path)
    @cache = cache || NoCache.new
  end

  def content
    @cache["#{self.key} -- content"] ||= @source_file.compiled
  end

  def fingerprint
    @cache["#{self.key} -- fingerprint"] ||= @source_file.fingerprint
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

  class NoCache
    def [](key); end
    def []=(key, value); end
  end

end
