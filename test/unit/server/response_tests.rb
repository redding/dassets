require "assert"
require "dassets/server/response"

require "rack/utils"
require "dassets/asset_file"

class Dassets::Server::Response
  class UnitTests < Assert::Context
    desc "Dassets::Server::Response"
    subject { @response }

    setup do
      @env = {}
      @asset_file = Dassets["file1.txt"]

      @response = Dassets::Server::Response.new(@env, @asset_file)
    end

    should have_readers :asset_file, :status, :headers, :body
    should have_imeths :to_rack

    should "handle not modified files" do
      env = { "HTTP_IF_MODIFIED_SINCE" => @asset_file.mtime }
      resp = Dassets::Server::Response.new(env, @asset_file)

      assert_that(resp.status).equals(304)
      assert_that(resp.body).equals([])

      exp_headers =
        Rack::Utils::HeaderHash.new("Last-Modified" => @asset_file.mtime.to_s)
      assert_that(resp.headers).equals(exp_headers)
      assert_that(resp.to_rack).equals([304, exp_headers.to_hash, []])
    end

    should "handle found files" do
      resp = Dassets::Server::Response.new(@env, @asset_file)

      assert_that(resp.status).equals(200)

      exp_body = Body.new(@env, @asset_file)
      assert_that(resp.body).equals(exp_body)

      exp_headers =
        @asset_file.response_headers.merge({
          "Content-Type"   => "text/plain",
          "Content-Length" => @asset_file.size.to_s,
          "Last-Modified"  => @asset_file.mtime.to_s,
        })
      assert_that(resp.headers).equals(exp_headers)

      assert_that(resp.to_rack).equals([200, exp_headers, exp_body])
    end

    should "have an empty body for found files with a HEAD request" do
      env = { "REQUEST_METHOD" => "HEAD" }
      resp = Dassets::Server::Response.new(env, @asset_file)

      assert_that(resp.status).equals(200)
      assert_that(resp.body).equals([])
    end

    should "handle not found files" do
      af   = Dassets.asset_file("not-found-file.txt")
      resp = Dassets::Server::Response.new(@env, af)

      assert_that(resp.status).equals(404)
      assert_that(resp.body).equals(["Not Found"])
      assert_that(resp.headers).equals(Rack::Utils::HeaderHash.new)
      assert_that(resp.to_rack).equals([404, {}, ["Not Found"]])
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
      assert_that(subject.status).equals(206)

      assert_that(subject.headers).includes("Content-Range")
      assert_that(subject.headers["Content-Range"]).equals(@body.content_range)
    end
  end

  class BodyTests < UnitTests
    desc "Body"
    subject { @body }

    setup do
      @body = Body.new(@env, @asset_file)
    end

    should have_readers :asset_file, :size, :content_range
    should have_imeths :partial?, :range_begin, :range_end
    should have_imeths :each

    should "know its chunk size" do
      assert_that(Body::CHUNK_SIZE).equals(8192)
    end

    should "know its asset file" do
      assert_that(subject.asset_file).equals(@asset_file)
    end

    should "know if it is equal to another body" do
      same_af_same_range = Body.new(@env, @asset_file)
      Assert.stub(same_af_same_range, :range_begin){ subject.range_begin }
      Assert.stub(same_af_same_range, :range_end){ subject.range_end }
      assert_that(subject).equals(same_af_same_range)

      other_af_same_range = Body.new(@env, Dassets["file2.txt"])
      Assert.stub(other_af_same_range, :range_begin){ subject.range_begin }
      Assert.stub(other_af_same_range, :range_end){ subject.range_end }
      assert_that(subject).does_not_equal(other_af_same_range)

      same_af_other_range = Body.new(@env, @asset_file)

      Assert.stub(same_af_other_range, :range_begin){ Factory.integer }
      Assert.stub(same_af_other_range, :range_end){ subject.range_end }
      assert_that(subject).does_not_equal(same_af_other_range)

      Assert.stub(same_af_other_range, :range_begin){ subject.range_begin }
      Assert.stub(same_af_other_range, :range_end){ Factory.integer }
      assert_that(subject).does_not_equal(same_af_other_range)
    end
  end

  class BodyIOTests < BodyTests
    setup do
      @min_num_chunks = 3
      @num_chunks     = @min_num_chunks + Factory.integer(3)

      content = "a" * (@num_chunks * Body::CHUNK_SIZE)
      Assert.stub(@asset_file, :content){ content }
    end
  end

  class NonPartialBodyTests < BodyIOTests
    desc "for non/multi/invalid partial content requests"

    setup do
      range = [nil, "bytes=", "bytes=0-1,2-3", "bytes=3-2", "bytes=abc"].sample
      env = range.nil? ? {} : { "HTTP_RANGE" => range }
      @body = Body.new(env, @asset_file)
    end

    should "not be partial" do
      assert_that(subject.partial?).is_false
    end

    should "be the full content size" do
      assert_that(subject.size).equals(@asset_file.size)
    end

    should "have no content range" do
      assert_that(subject.content_range).is_nil
    end

    should "have the full content size as its range" do
      assert_that(subject.range_begin).equals(0)
      assert_that(subject.range_end).equals(subject.size - 1)
    end

    should "chunk the full content when iterated" do
      chunks = []
      subject.each{ |chunk| chunks << chunk }

      assert_that(chunks.size).equals(@num_chunks)
      assert_that(chunks.first.size).equals(subject.class::CHUNK_SIZE)
      assert_that(chunks.join("")).equals(@asset_file.content)
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

      @env = { "HTTP_RANGE" => "bytes=#{@partial_begin}-#{@partial_end}" }
    end
  end

  class PartialBodyTests < PartialBodySetupTests
    subject { @body }

    setup do
      @body = Body.new(@env, @asset_file)
    end

    should "be partial" do
      assert_that(subject.partial?).is_true
    end

    should "be the specified partial size" do
      assert_that(subject.size).equals(@partial_size)
    end

    should "know its content range" do
      exp = "bytes #{@partial_begin}-#{@partial_end}/#{@asset_file.size}"
      assert_that(subject.content_range).equals(exp)
    end

    should "have the know its range" do
      assert_that(subject.range_begin).equals(@partial_begin)
      assert_that(subject.range_end).equals(@partial_end)
    end

    should "chunk the range when iterated" do
      chunks = []
      subject.each{ |chunk| chunks << chunk }

      assert_that(chunks.size).equals(@partial_chunks)
      assert_that(chunks.first.size).equals(subject.class::CHUNK_SIZE)

      exp = @asset_file.content[@partial_begin..@partial_end]
      assert_that(chunks.join("")).equals(exp)
    end
  end

  class LegacyRackTests < PartialBodySetupTests
    desc "when using a legacy version of rack that can't interpret byte ranges"

    setup do
      Assert.stub(Rack::Utils, :respond_to?).with(:byte_ranges){ false }
      @body = Body.new(@env, @asset_file)
    end

    should "not be partial" do
      assert_that(subject.partial?).is_false
    end

    should "be the full content size" do
      assert_that(subject.size).equals(@asset_file.size)
    end

    should "have no content range" do
      assert_that(subject.content_range).is_nil
    end

    should "have the full content size as its range" do
      assert_that(subject.range_begin).equals(0)
      assert_that(subject.range_end).equals(subject.size - 1)
    end

    should "chunk the full content when iterated" do
      chunks = []
      subject.each{ |chunk| chunks << chunk }

      assert_that(chunks.size).equals(@num_chunks)
      assert_that(chunks.first.size).equals(subject.class::CHUNK_SIZE)
      assert_that(chunks.join("")).equals(@asset_file.content)
    end
  end
end
