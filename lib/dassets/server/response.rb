require 'rack/response'
require 'rack/utils'
require 'rack/mime'

class Dassets::Server

  class Response
    attr_reader :asset_file, :status, :headers, :body

    def initialize(env, asset_file)
      @asset_file = asset_file

      mtime = @asset_file.mtime.to_s
      @status, @headers, @body = if env['HTTP_IF_MODIFIED_SINCE'] == mtime
        [ 304, Rack::Utils::HeaderHash.new, [] ]
      elsif !@asset_file.exists?
        [ 404, Rack::Utils::HeaderHash.new, ["Not Found"] ]
      else
        @asset_file.digest!
        [ 200,
          Rack::Utils::HeaderHash.new.tap do |h|
            h["Content-Type"]   = @asset_file.mime_type.to_s
            h["Content-Length"] = @asset_file.size.to_s
            h["Last-Modified"]  = mtime
          end,
          env["REQUEST_METHOD"] == "HEAD" ? [] : [ @asset_file.content ]
        ]
      end
    end

    def to_rack
      [@status, @headers.to_hash, @body]
    end

  end

end
