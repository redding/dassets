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

  def run(io=nil)
    files = paths

    if @paths.empty?
      log io, "clearing `#{Dassets.config.output_path}`"
      clear_output_path(Dassets.config.output_path)

      # always clear the digests in use
      log io, "clearing `#{Dassets.digests.file_path}`"
      clear_digests(Dassets.digests)

      # always get the latest source list
      files = Dassets::SourceList.new(Dassets.config)
    end

    log io, "digesting #{files.count} source file(s) ..."
    digest_the_files(files)
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

  def log(io, msg)
    io.puts msg if io
  end

end

