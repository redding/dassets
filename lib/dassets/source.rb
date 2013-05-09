module Dassets; end
class Dassets::Source

  attr_reader :path
  attr_accessor :filter

  def initialize(path)
    @path = path
    @filter = proc{ |paths| paths }
  end

  def files
    apply_filter(glob_files).sort
  end

  private

  def glob_files
    Dir.glob(File.join(@path, "**/*"  )).reject!{ |p| !File.file?(p) }
  end

  def apply_filter(files)
    @filter.call(files)
  end

end
