require 'dassets/engine'

module Dassets; end
class Dassets::Source

  attr_reader :path, :engines, :response_headers

  def initialize(path)
    @path = path.to_s
    @filter = proc{ |paths| paths }
    @engines = Hash.new{ |h,k| Dassets::NullEngine.new }
    @response_headers = Hash.new
  end

  def filter(&block)
    block.nil? ? @filter : @filter = block
  end

  def engine(input_ext, engine_class, registered_opts=nil)
    default_opts = { 'source_path' => @path }
    engine_opts = default_opts.merge(registered_opts || {})
    @engines[input_ext.to_s] = engine_class.new(engine_opts)
  end

  def files
    apply_filter(glob_files || []).sort
  end

  private

  def glob_files
    Dir.glob(File.join(@path, "**/*")).reject!{ |p| !File.file?(p) }
  end

  def apply_filter(files)
    @filter.call(files)
  end

end
