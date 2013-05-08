require 'digest/md5'
require 'dassets/source_file'

module Dassets; end
class Dassets::SourceProxy

  attr_reader :digest_path, :source_files, :cache

  def initialize(digest_path, cache=nil)
    @digest_path  = digest_path
    @source_files = get_source_files(@digest_path)
    @cache = cache || NoCache.new
  end

  def key
    "#{self.digest_path} -- #{self.mtime}"
  end

  def content
    @cache["#{self.key} -- content"] ||= source_content
  end

  def fingerprint
    @cache["#{self.key} -- fingerprint"] ||= source_fingerprint
  end

  def mtime
    @source_files.map{ |f| f.mtime }.max
  end

  def exists?
    @source_files.inject(true){ |res, f| res && f.exists? }
  end

  private

  def source_content
    @source_content ||= @source_files.map{ |f| f.compiled }.join("\n")
  end

  def source_fingerprint
    @source_fingerprint ||= Digest::MD5.new.hexdigest(source_content)
  end

  def get_source_files(digest_path)
    # TODO: Dassets.config.combinations[digest_path]
    [digest_path].map do |source_digest_path|
      Dassets::SourceFile.find_by_digest_path(source_digest_path)
    end
  end

  class NoCache
    def [](key); end
    def []=(key, value); end
  end

end
