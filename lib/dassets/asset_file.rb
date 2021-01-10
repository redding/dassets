# frozen_string_literal: true

require "dassets/source_proxy"
require "rack/utils"
require "rack/mime"

module Dassets; end

class Dassets::AssetFile
  attr_reader :digest_path, :dirname, :extname, :basename, :source_proxy

  def initialize(digest_path)
    @digest_path  = digest_path
    @dirname      = File.dirname(@digest_path)
    @extname      = File.extname(@digest_path)
    @basename     = File.basename(@digest_path, @extname)
    @source_proxy =
      Dassets::SourceProxy.new(
        @digest_path,
        content_cache:     Dassets.config.content_cache,
        fingerprint_cache: Dassets.config.fingerprint_cache,
      )
  end

  def digest!
    return unless exists?
    Dassets.config.file_store.save(url){ content }
  end

  def url
    path_basename = "#{@basename}-#{fingerprint}#{@extname}"
    path =
      File.join(@dirname, path_basename).sub(%r{^\./}, "").sub(%r{^/}, "")
    "#{dassets_base_url}/#{path}"
  end
  alias_method :href, :url

  def fingerprint
    return nil unless exists?
    @source_proxy.fingerprint
  end

  def content
    return nil unless exists?
    @source_proxy.content
  end

  def mtime
    return nil unless exists?
    @source_proxy.mtime.httpdate
  end

  def size
    return nil unless exists?
    content.bytesize
  end

  def mime_type
    return nil unless exists?
    Rack::Mime.mime_type(@extname)
  end

  def response_headers
    @source_proxy.response_headers
  end

  def exists?
    @source_proxy.exists?
  end

  def ==(other)
    other.is_a?(Dassets::AssetFile) &&
    digest_path == other.digest_path &&
    fingerprint == other.fingerprint
  end

  private

  def dassets_base_url
    Dassets.config.base_url.to_s
  end
end
