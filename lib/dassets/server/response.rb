require 'rack/response'
require 'rack/utils'
require 'rack/mime'

module Dassets; end
class Dassets::Server

  class Response

    attr_reader :asset_file, :status, :headers, :body

    def initialize(env, asset_file)
      @asset_file = asset_file

      mtime = @asset_file.mtime.to_s
      @status, @headers, @body = if env['HTTP_IF_MODIFIED_SINCE'] == mtime
        [ 304, Rack::Utils::HeaderHash.new('Last-Modified' => mtime), [] ]
      elsif !@asset_file.exists?
        [ 404, Rack::Utils::HeaderHash.new, ["Not Found"] ]
      else
        @asset_file.digest!
        body = Body.new(env, @asset_file)
        [ body.partial? ? 206 : 200,
          Rack::Utils::HeaderHash.new.tap do |h|
            h['Last-Modified']  = mtime
            h['Content-Type']   = @asset_file.mime_type.to_s
            h['Content-Length'] = body.size.to_s
            h['Content-Range']  = body.content_range if body.partial?
          end,
          env["REQUEST_METHOD"] == "HEAD" ? [] : body
        ]
      end
    end

    def to_rack
      [@status, @headers.to_hash, @body]
    end

    class Body

      # this class borrows from the body range handling in Rack::File and adapts
      # it for use with Dasset's asset files and their generic string content.

      CHUNK_SIZE = (8*1024).freeze # 8k

      attr_reader :asset_file, :size, :content_range

      def initialize(env, asset_file)
        @asset_file = asset_file

        content_size = @asset_file.size
        ranges = Rack::Utils.byte_ranges(env, content_size)
        if ranges.nil? || ranges.empty? || ranges.length > 1
          # No ranges or multiple ranges are not supported
          @range         = 0..content_size-1
          @content_range = nil
        else
          # single range
          @range         = ranges[0]
          @content_range = "bytes #{@range.begin}-#{@range.end}/#{content_size}"
        end

        @size = self.range_end - self.range_begin + 1
      end

      def partial?
        !@content_range.nil?
      end

      def range_begin; @range.begin; end
      def range_end;   @range.end;   end

      def each
        StringIO.open(@asset_file.content, "rb") do |io|
          io.seek(@range.begin)
          remaining_len = self.size
          while remaining_len > 0
            part = io.read([CHUNK_SIZE, remaining_len].min)
            break if part.nil?

            remaining_len -= part.length
            yield part
          end
        end
      end

      def inspect
        "#<#{self.class}:#{'0x0%x' % (self.object_id << 1)} " \
          "digest_path=#{self.asset_file.digest_path} " \
          "range_begin=#{self.range_begin} range_end=#{self.range_end}>"
      end

      def ==(other_body)
        self.asset_file  == other_body.asset_file  &&
        self.range_begin == other_body.range_begin &&
        self.range_end   == other_body.range_end
      end

    end

  end

end
