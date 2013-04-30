require 'fileutils'
require 'dassets'
require 'dassets/source_file'

module Dassets; end
class Dassets::DigestCmd

  attr_reader :paths

  def initialize(abs_paths)
    @paths = abs_paths || []
  end

  def run(io=nil)
    files = @paths
    if @paths.empty?
      # always get the latest source list
      files = Dassets::SourceList.new(Dassets.config)
    end

    log io, "digesting #{files.count} source file(s) ..."
    digest_the_files(files)
  end

  private

  def digest_the_files(files)
    files.each{ |f| Dassets::SourceFile.new(f).asset_file.digest! }
  end

  def log(io, msg)
    io.puts msg if io
  end

end

