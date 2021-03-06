# frozen_string_literal: true

require "dassets/engine"

module Dassets; end

class Dassets::Source
  attr_reader :path, :engines, :response_headers

  def initialize(path)
    @path             = path.to_s
    @filter           = proc{ |paths| paths }
    @engines          = Hash.new{ |hash, key| hash[key] = [] }
    @response_headers = {}
  end

  def base_path(value = nil)
    set_base_path(value) unless value.nil?
    @base_path
  end

  def set_base_path(value)
    @base_path = value
  end

  def filter(&block)
    block.nil? ? @filter : @filter = block
  end

  def engine(input_ext, engine_class, registered_opts = nil)
    default_opts = { "source_path" => @path }
    engine_opts = default_opts.merge(registered_opts || {})
    @engines[input_ext.to_s] << engine_class.new(engine_opts)
  end

  def files
    apply_filter(glob_files || []).sort
  end

  private

  # Use "**{,/*/**}/*" to glob following symlinks and returning immediate-child
  # matches. See https://stackoverflow.com/a/2724048.
  def glob_files
    Dir
      .glob(File.join(@path, "**{,/*/**}/*"))
      .uniq
      .reject{ |path| !File.file?(path) }
  end

  def apply_filter(files)
    @filter.call(files)
  end
end
