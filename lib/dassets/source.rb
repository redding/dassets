require 'dassets/engine'

module Dassets; end
class Dassets::Source

  attr_reader :path, :engines
  attr_accessor :filter

  def initialize(path)
    @path = path
    @filter = proc{ |paths| paths }
    @engines = Hash.new{ |h,k| Dassets::NullEngine.new }
  end

  def engine(input_ext, engine_class, opts=nil)
    @engines[input_ext.to_s] = engine_class.new(opts)
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
