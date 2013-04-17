require 'rack/request'

class Dassets::Server

  class Request < Rack::Request

    # The HTTP request method. This is the standard implementation of this
    # method but is respecified here due to libraries that attempt to modify
    # the behavior to respect POST tunnel method specifiers. We always want
    # the real request method.
    def request_method; @env['REQUEST_METHOD']; end
    def path_info;      @env['PATH_INFO'];      end

    # Determine if the request is for an asset file
    # This will be called on every request so speed is an issue
    # - first check if the request is a GET (fast)
    # - then check if for a digest resource (kinda fast)
    # - then check if on a path in the digests (slower)
    def for_asset_file?
      !!(get? && for_digest_file? && Dassets.digests[asset_path])
    end

    def asset_path
      @asset_path ||= path_digest_match.captures.select{ |m| !m.empty? }.join
    end

    def asset_file
      @asset_file ||= Dassets[asset_path]
    end

    private

    def for_digest_file?
      !path_digest_match.nil?
    end

    def path_digest_match
      @path_digest_match ||= begin
        path_info.match(/\/(.+)-[a-f0-9]{32}(\..+|)$/i) || NullDigestMatch.new
      end
    end

    class NullDigestMatch
      def captures; []; end
    end

  end
end
