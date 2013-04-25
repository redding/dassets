require 'fileutils'
require 'dassets'
require 'dassets/source_file'

module Dassets; end
class Dassets::Cmds; end
class Dassets::Cmds::DigestCmd

  def self.for(abs_paths)
    source_paths, opts = abs_paths, {}

    if source_paths.empty?
      # clear the output path and digests, then digest all of the sources
      opts[:clear_output_path] = Dassets.config.output_path
      opts[:clear_digests] = Dassets.digests
      source_paths = Dassets::SourceList.new(Dassets.config)
    end

    self.new(source_paths, opts)
  end

  attr_reader :source_paths, :opts

  def initialize(source_paths, opts={})
    @source_paths = source_paths
    @opts = opts
  end

  # TODO: io to output to
  def run
    clear_output_path(@opts[:clear_output_path])
    clear_digests(@opts[:clear_digests])
    digest_the_files(@source_paths)
  end

  private

  def clear_output_path(path)
    Dir.glob(File.join(path, '*')).each{ |p| FileUtils.rm_r(p) } if path
  end

  def clear_digests(digests)
    digests.clear.save! if digests
  end

  def digest_the_files(files)
    files.map{ |f| Dassets::SourceFile.new(f).digest }
  end

end

