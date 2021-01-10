# frozen_string_literal: true

require "assert"
require "dassets/source"

require "dassets/engine"

class Dassets::Source
  class UnitTests < Assert::Context
    desc "Dassets::Source"
    subject{ Dassets::Source.new(@source_path) }

    setup do
      @source_path = TEST_SUPPORT_PATH.join("source_files")
    end

    should have_reader :path, :engines, :response_headers
    should have_imeth :files, :filter, :engine

    should "know its path and default filter" do
      assert_that(subject.path).equals(@source_path.to_s)
      assert_that(subject.filter).is_kind_of(Proc)
      assert_that(subject.filter.call(["file1", "file2"]))
        .equals(["file1", "file2"])
    end

    should "know its files" do
      exp_files = [
        @source_path.join("test1.txt").to_s,
        @source_path.join("_ignored.txt").to_s,
        @source_path.join("nested/test2.txt").to_s,
        @source_path.join("nested/_nested_ignored.txt").to_s,
        @source_path.join("linked/linked_file.txt").to_s,
        @source_path.join("linked_file2.txt").to_s,
      ].sort
      assert_that(subject.files).equals(exp_files)
    end

    should "run the supplied source filter on the paths" do
      subject.filter do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      exp_files = [
        @source_path.join("test1.txt").to_s,
        @source_path.join("nested/test2.txt").to_s,
        @source_path.join("linked/linked_file.txt").to_s,
        @source_path.join("linked_file2.txt").to_s,
      ].sort

      assert_that(subject.files).equals(exp_files)
    end

    should "know its extension-specific engines and return an empty Array by "\
           "default" do
      assert_that(subject.engines).is_kind_of(::Hash)
      assert_that(subject.engines["something"]).equals([])
    end

    should "know its response headers" do
      assert_that(subject.response_headers).equals({})

      name, value = Factory.string, Factory.string
      subject.response_headers[name] = value
      assert_that(subject.response_headers[name]).equals(value)
    end
  end

  class EmptySourceTests < UnitTests
    desc "with no source files"

    setup do
      @empty_source_path = TEST_SUPPORT_PATH.join("empty")
      @empty_source = Dassets::Source.new(@empty_source_path)

      @no_exist_source_path = TEST_SUPPORT_PATH.join("does-not-exist")
      @no_exist_source = Dassets::Source.new(@no_exist_source_path)
    end

    should "have no files" do
      assert_that(@empty_source.files).is_empty
      assert_that(@no_exist_source.files).is_empty
    end

    should "hand filters an empty path list" do
      @empty_source.filter do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end
      @no_exist_source.filter do |paths|
        paths.reject{ |path| File.basename(path) =~ /^_/ }
      end

      assert_that(@empty_source.files).is_empty
      assert_that(@no_exist_source.files).is_empty
    end
  end

  class EngineRegistrationTests < UnitTests
    desc "when registering an engine"

    setup do
      @empty_engine =
        Class.new(Dassets::Engine) do
          def ext(_input_ext)
            ""
          end

          def compile(_input)
            ""
          end
        end
    end

    should "allow registering new engines" do
      assert_that(subject.engines["empty"]).equals([])

      subject.engine "empty", @empty_engine, "an" => "opt"
      assert_that(subject.engines["empty"]).is_kind_of(Array)
      assert_that(subject.engines["empty"].size).equals(1)
      assert_that(subject.engines["empty"].first.opts["an"]).equals("opt")
      assert_that(subject.engines["empty"].first.ext("empty")).equals("")
      assert_that(subject.engines["empty"].first.compile("some content"))
        .equals("")
    end

    should "register with the source path as a default option" do
      subject.engine "empty", @empty_engine
      exp_opts = { "source_path" => subject.path }
      assert_that(subject.engines["empty"].first.opts).equals(exp_opts)

      subject.engines["empty"] = []
      subject.engine "empty", @empty_engine, "an" => "opt"
      exp_opts = {
        "source_path" => subject.path,
        "an" => "opt",
      }
      assert_that(subject.engines["empty"].first.opts).equals(exp_opts)

      subject.engines["empty"] = []
      subject.engine "empty", @empty_engine, "source_path" => "something"
      exp_opts = { "source_path" => "something" }
      assert_that(subject.engines["empty"].first.opts).equals(exp_opts)
    end
  end
end
