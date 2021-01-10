# frozen_string_literal: true

require "digest/md5"
require "dassets/cache"
require "dassets/source_file"

module Dassets; end

class Dassets::SourceProxy
  attr_reader :digest_path, :content_cache, :fingerprint_cache
  attr_reader :source_files

  def initialize(digest_path, **options)
    @digest_path       = digest_path
    @content_cache     = options[:content_cache]     || Dassets::NoCache.new
    @fingerprint_cache = options[:fingerprint_cache] || Dassets::NoCache.new
    @source_files      =
      get_source_files(
        @digest_path,
        content_cache:     @content_cache,
        fingerprint_cache: @fingerprint_cache,
      )
  end

  def key
    "#{digest_path} -- #{mtime}"
  end

  def content
    @content_cache[key] ||= source_content
  end

  def fingerprint
    @fingerprint_cache[key] ||= source_fingerprint
  end

  def mtime
    @source_files.map(&:mtime).compact.max
  end

  def response_headers
    @source_files.inject({}){ |hash, f| hash.merge!(f.response_headers) }
  end

  def exists?
    @source_files.inject(true){ |res, f| res && f.exists? }
  end

  private

  def source_content
    @source_files.map(&:compiled).join("\n")
  end

  def source_fingerprint
    Digest::MD5.new.hexdigest(source_content)
  end

  def get_source_files(digest_path, **options)
    Dassets.config.combinations[digest_path.to_s].map do |source_digest_path|
      Dassets::SourceFile.find_by_digest_path(source_digest_path, **options)
    end
  end
end

class Dassets::NullSourceProxy
  def content
    nil
  end

  def exists?
    false
  end

  def mtime
    nil
  end
end
