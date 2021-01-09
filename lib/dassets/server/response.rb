# frozen_string_literal: true

require "rack/response"
require "rack/utils"
require "rack/mime"

module Dassets; end
class Dassets::Server; end

class Dassets::Server::Response
  attr_reader :asset_file, :status, :headers, :body

  def initialize(env, asset_file)
    @asset_file = asset_file

    mtime = @asset_file.mtime.to_s
    @status, @headers, @body = if env["HTTP_IF_MODIFIED_SINCE"] == mtime
      [
        304,
        Rack::Utils::HeaderHash.new("Last-Modified" => mtime),
        [],
      ]
    elsif !@asset_file.exists?
      [
        404,
        Rack::Utils::HeaderHash.new,
        ["Not Found"],
      ]
    else
      @asset_file.digest!
      body = Body.new(env, @asset_file)
      [
        body.partial? ? 206 : 200,
        Rack::Utils::HeaderHash
          .new
          .merge(@asset_file.response_headers).tap do |h|
            h["Last-Modified"]  = mtime.to_s
            h["Content-Type"]   = @asset_file.mime_type.to_s
            h["Content-Length"] = body.size.to_s
            h["Content-Range"]  = body.content_range if body.partial?
          end,
        env["REQUEST_METHOD"] == "HEAD" ? [] : body,
      ]
    end
  end

  def to_rack
    [@status, @headers.to_hash, @body]
  end

  # This class borrows from the body range handling in Rack::File and adapts
  # it for use with Dasset's asset files and their generic string content.
  class Body
    CHUNK_SIZE = (8 * 1024) # 8k

    attr_reader :asset_file, :size, :content_range

    def initialize(env, asset_file)
      @asset_file = asset_file
      @range, @content_range = get_range_info(env, @asset_file)
      @size = range_end - range_begin + 1
    end

    def partial?
      !@content_range.nil?
    end

    def range_begin
      @range.begin
    end

    def range_end
      @range.end
    end

    def each
      StringIO.open(@asset_file.content, "rb") do |io|
        io.seek(@range.begin)
        remaining_len = size
        while remaining_len > 0
          part = io.read([CHUNK_SIZE, remaining_len].min)
          break if part.nil?

          remaining_len -= part.length
          yield part
        end
      end
    end

    def inspect
      "#<#{self.class}:#{"0x0%x" % (object_id << 1)} " \
        "digest_path=#{asset_file.digest_path} " \
        "range_begin=#{range_begin} range_end=#{range_end}>"
    end

    def ==(other)
      if other.is_a?(self.class)
        asset_file  == other.asset_file  &&
        range_begin == other.range_begin &&
        range_end   == other.range_end
      else
        super
      end
    end

    private

    def get_range_info(env, asset_file)
      content_size = asset_file.size
      # legacy rack version, just return full size
      unless Rack::Utils.respond_to?(:byte_ranges)
        return full_size_range_info(content_size)
      end

      ranges = Rack::Utils.byte_ranges(env, content_size)
      # No ranges or multiple ranges are not supported, just return full size
      if ranges.nil? || ranges.empty? || ranges.length > 1
        return full_size_range_info(content_size)
      end

      # single range
      [ranges[0], "bytes #{ranges[0].begin}-#{ranges[0].end}/#{content_size}"]
    end

    def full_size_range_info(content_size)
      [(0..content_size - 1), nil]
    end
  end
end
