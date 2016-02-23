require 'assert'
require 'dassets/server/response'

require 'rack/utils'
require 'dassets/asset_file'

class Dassets::Server::Response

  class UnitTests < Assert::Context
    desc "Dassets::Server::Response"
    setup do
      @env        = {}
      @asset_file = Dassets['file1.txt']

      @response = Dassets::Server::Response.new(@env, @asset_file)
    end
    subject{ @response }

    should have_readers :asset_file, :status, :headers, :body
    should have_imeths :to_rack

    should "handle not modified files" do
      env = { 'HTTP_IF_MODIFIED_SINCE' => @asset_file.mtime }
      resp = Dassets::Server::Response.new(env, @asset_file)

      assert_equal 304, resp.status
      assert_equal [],  resp.body

      exp_headers = Rack::Utils::HeaderHash.new('Last-Modified' => @asset_file.mtime.to_s)
      assert_equal exp_headers, resp.headers

      assert_equal [304, exp_headers.to_hash, []], resp.to_rack
    end

    should "handle found files" do
      resp = Dassets::Server::Response.new(@env, @asset_file)

      assert_equal 200, resp.status

      exp_body = Body.new(@env, @asset_file)
      assert_equal exp_body, resp.body

      exp_headers = @asset_file.response_headers.merge({
        'Content-Type'   => 'text/plain',
        'Content-Length' => Rack::Utils.bytesize(@asset_file.content).to_s,
        'Last-Modified'  => @asset_file.mtime.to_s
      })
      assert_equal exp_headers, resp.headers

      assert_equal [200, exp_headers, exp_body], resp.to_rack
    end

    should "have an empty body for found files with a HEAD request" do
      env = { 'REQUEST_METHOD' => 'HEAD' }
      resp = Dassets::Server::Response.new(env, @asset_file)

      assert_equal 200, resp.status
      assert_equal [], resp.body
    end

    should "handle not found files" do
      af   = Dassets['not-found-file.txt']
      resp = Dassets::Server::Response.new(@env, af)

      assert_equal 404,                         resp.status
      assert_equal ['Not Found'],               resp.body
      assert_equal Rack::Utils::HeaderHash.new, resp.headers
      assert_equal [404, {}, ['Not Found']],    resp.to_rack
    end

  end

  class PartialContentTests < UnitTests
    desc "for a partial content request"
    setup do
      @body = Body.new(@env, @asset_file)
      Assert.stub(Body, :new).with(@env, @asset_file){ @body }

      content_range = Factory.string
      Assert.stub(@body, :content_range){ content_range }
      Assert.stub(@body, :partial?){ true }

      @response = Dassets::Server::Response.new(@env, @asset_file)
    end

    should "be a partial content response" do
      assert_equal 206, subject.status

      assert_includes 'Content-Range', subject.headers
      assert_equal @body.content_range, subject.headers['Content-Range']
    end

  end

  class BodyTests < UnitTests
    desc "Body"
    setup do
      @body = Body.new(@env, @asset_file)
    end
    subject{ @body }

    should have_readers :asset_file, :size, :content_range
    should have_imeths :partial?, :range_begin, :range_end
    should have_imeths :each

    should "know its chunk size" do
      assert_equal 8192, Body::CHUNK_SIZE
    end

    should "know its asset file" do
      assert_equal @asset_file, subject.asset_file
    end

    should "know if it is equal to another body" do
      same_af_same_range = Body.new(@env, @asset_file)
      Assert.stub(same_af_same_range, :range_begin){ subject.range_begin }
      Assert.stub(same_af_same_range, :range_end){ subject.range_end }
      assert_equal same_af_same_range, subject

      other_af_same_range = Body.new(@env, Dassets['file2.txt'])
      Assert.stub(other_af_same_range, :range_begin){ subject.range_begin }
      Assert.stub(other_af_same_range, :range_end){ subject.range_end }
      assert_not_equal other_af_same_range, subject

      same_af_other_range = Body.new(@env, @asset_file)

      Assert.stub(same_af_other_range, :range_begin){ Factory.integer }
      Assert.stub(same_af_other_range, :range_end){ subject.range_end }
      assert_not_equal same_af_other_range, subject

      Assert.stub(same_af_other_range, :range_begin){ subject.range_begin }
      Assert.stub(same_af_other_range, :range_end){ Factory.integer }
      assert_not_equal same_af_other_range, subject
    end

  end

  class BodyIOTests < BodyTests
    setup do
      @min_num_chunks = 3
      @num_chunks     = @min_num_chunks + Factory.integer(3)

      content = 'a' * (@num_chunks * Body::CHUNK_SIZE)
      Assert.stub(@asset_file, :content){ content }
    end

  end

  class NonPartialBodyTests < BodyIOTests
    desc "for non/multi/invalid partial content requests"
    setup do
      range = [nil, 'bytes=', 'bytes=0-1,2-3', 'bytes=3-2', 'bytes=abc'].choice
      env = range.nil? ? {} : { 'HTTP_RANGE' => range }
      @body = Body.new(env, @asset_file)
    end

    should "not be partial" do
      assert_false subject.partial?
    end

    should "be the full content size" do
      assert_equal @asset_file.size, subject.size
    end

    should "have no content range" do
      assert_nil subject.content_range
    end

    should "have the full content size as its range" do
      assert_equal 0,              subject.range_begin
      assert_equal subject.size-1, subject.range_end
    end

    should "chunk the full content when iterated" do
      chunks = []
      subject.each{ |chunk| chunks << chunk }

      assert_equal @num_chunks,               chunks.size
      assert_equal subject.class::CHUNK_SIZE, chunks.first.size
      assert_equal @asset_file.content,       chunks.join('')
    end

  end

  class PartialBodySetupTests < BodyIOTests
    desc "for a partial content request"
    setup do
      @start_chunk    = Factory.boolean ? 0 : 1
      @partial_begin  = @start_chunk * Body::CHUNK_SIZE
      @partial_chunks = @num_chunks - Factory.integer(@min_num_chunks)
      @partial_size   = @partial_chunks * Body::CHUNK_SIZE
      @partial_end    = @partial_begin + (@partial_size-1)

      @env = { 'HTTP_RANGE' => "bytes=#{@partial_begin}-#{@partial_end}" }
    end

  end

  class PartialBodyTests < PartialBodySetupTests
    setup do
      @body = Body.new(@env, @asset_file)
    end
    subject{ @body }

    should "be partial" do
      assert_true subject.partial?
    end

    should "be the specified partial size" do
      assert_equal @partial_size, subject.size
    end

    should "know its content range" do
      exp = "bytes #{@partial_begin}-#{@partial_end}/#{@asset_file.size}"
      assert_equal exp, subject.content_range
    end

    should "have the know its range" do
      assert_equal @partial_begin, subject.range_begin
      assert_equal @partial_end,   subject.range_end
    end

    should "chunk the range when iterated" do
      chunks = []
      subject.each{ |chunk| chunks << chunk }

      assert_equal @partial_chunks,           chunks.size
      assert_equal subject.class::CHUNK_SIZE, chunks.first.size

      exp = @asset_file.content[@partial_begin..@partial_end]
      assert_equal exp, chunks.join('')
    end

  end

  class LegacyRackTests < PartialBodySetupTests
    desc "when using a legacy version of rack that can't interpret byte ranges"
    setup do
      Assert.stub(Rack::Utils, :respond_to?).with(:byte_ranges){ false }
      @body = Body.new(@env, @asset_file)
    end

    should "not be partial" do
      assert_false subject.partial?
    end

    should "be the full content size" do
      assert_equal @asset_file.size, subject.size
    end

    should "have no content range" do
      assert_nil subject.content_range
    end

    should "have the full content size as its range" do
      assert_equal 0,              subject.range_begin
      assert_equal subject.size-1, subject.range_end
    end

    should "chunk the full content when iterated" do
      chunks = []
      subject.each{ |chunk| chunks << chunk }

      assert_equal @num_chunks,               chunks.size
      assert_equal subject.class::CHUNK_SIZE, chunks.first.size
      assert_equal @asset_file.content,       chunks.join('')
    end

  end

end
