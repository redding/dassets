# frozen_string_literal: true

require "fileutils"
require "dassets"
require "dassets/asset_file"
require "dassets/source_proxy"

module Dassets; end

class Dassets::SourceFile
  def self.find_by_digest_path(path, **options)
    Dassets.source_files[path] || Dassets::NullSourceFile.new(path, **options)
  end

  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path.to_s
    @ext_list  = File.basename(@file_path).split(".").reverse
  end

  # Get the last matching one (in the case two sources with the same path are
  # configured) since we select the last matching source file (from the last
  # configured source) in `find_by_digest_path` above.
  def source
    @source ||=
      Dassets.config.sources.select{ |source|
        @file_path =~ /^#{slash_path(source.path)}/
      }.last
  end

  def asset_file
    @asset_file ||= Dassets::AssetFile.new(digest_path)
  end

  def digest_path
    @digest_path ||=
      begin
        digest_basename =
          @ext_list
            .reduce([]){ |digest_ext_list, ext|
              digest_ext_list <<
                source.engines[ext].reduce(ext)do |ext_acc, engine|
                  engine.ext(ext_acc)
                end
            }
            .reject(&:empty?)
            .reverse
            .join(".")

        File.join(
          [
            base_path,
            digest_dirname(@file_path),
            digest_basename,
          ].reject(&:empty?),
        )
      end
  end

  def compiled
    @ext_list.reduce(read_file(@file_path)) do |file_acc, ext|
      source.engines[ext].reduce(file_acc) do |ext_acc, engine|
        engine.compile(ext_acc)
      end
    end
  end

  def exists?
    File.file?(@file_path)
  end

  def mtime
    File.mtime(@file_path)
  end

  def base_path
    source&.base_path.to_s
  end

  def response_headers
    source.nil? ? {} : source.response_headers
  end

  def ==(other)
    if other.is_a?(self.class)
      file_path == other.file_path
    else
      super
    end
  end

  private

  # remove the source path from the dirname (if it exists)
  def digest_dirname(file_path)
    slash_path(File.dirname(file_path)).sub(slash_path(source.path), "")
  end

  def slash_path(path)
    File.join(path, "")
  end

  def read_file(path)
    File.send(File.respond_to?(:binread) ? :binread : :read, path.to_s)
  end
end

# A null source file is used to represent source that either doesn't exist
# or source that is a proxy (ie a combination)
class Dassets::NullSourceFile < Dassets::SourceFile
  def initialize(digest_path, **options)
    @file_path    = ""
    @ext_list     = []
    @digest_path  = digest_path
    @source_proxy =
      if Dassets.config.combination?(@digest_path)
        Dassets::SourceProxy.new(@digest_path, **options)
      else
        Dassets::NullSourceProxy.new
      end
  end

  def compiled
    @source_proxy.content
  end

  def exists?
    @source_proxy.exists?
  end

  def mtime
    @source_proxy.mtime
  end

  def ==(other)
    if other.is_a?(self.class)
      file_path == other.file_path
    else
      super
    end
  end
end
