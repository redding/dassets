# frozen_string_literal: true

require "rack"

module Dassets; end
class Dassets::Server; end

class Dassets::Server::Request < Rack::Request
  # The HTTP request method. This is the standard implementation of this
  # method but is respecified here due to libraries that attempt to modify
  # the behavior to respect POST tunnel method specifiers. We always want
  # the real request method.
  def request_method
    @env["REQUEST_METHOD"]
  end

  def path_info
    @env["PATH_INFO"].sub(dassets_base_url, "")
  end

  def dassets_base_url
    Dassets.config.base_url.to_s
  end

  # Determine if the request is for an asset file
  # This will be called on every request so speed is an issue
  # - first check if the request is a GET or HEAD (fast)
  # - then check if for a digested asset resource (kinda fast)
  # - then check if source exists for the digested asset (slower)
  def for_asset_file?
    !!((get? || head?) && for_digested_asset? && asset_file.exists?)
  end

  def asset_path
    @asset_path ||= path_digest_match.captures.select{ |m| !m.empty? }.join
  end

  def asset_file
    @asset_file ||= Dassets.asset_file(asset_path)
  end

  private

  def for_digested_asset?
    !path_digest_match.captures.empty?
  end

  def path_digest_match
    @path_digest_match ||= begin
      path_info.match(%r{/(.+)-[a-f0-9]{32}(\..+|)$}i) || NullDigestMatch.new
    end
  end

  class NullDigestMatch
    def captures
      []
    end
  end
end
