require 'fileutils'
require 'dassets'
require 'dassets/source_file'

module Dassets; end
class Dassets::Cmds; end
class Dassets::Cmds::DigestCmd

  attr_reader :paths

  def initialize(abs_paths)
    @paths = abs_paths || []
  end

  def run # TODO: io to output to
    if @paths.empty?
      clear_output_path(Dassets.config.output_path)

      # always clear the digests in use
      clear_digests(Dassets.digests)

      # always get the latest source list
      digest_the_files(Dassets::SourceList.new(Dassets.config))
    else
      digest_the_files(@paths)
    end
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

