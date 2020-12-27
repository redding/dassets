# frozen_string_literal: true

module Dassets; end

class Dassets::Engine
  attr_reader :opts

  def initialize(opts = nil)
    @opts = opts || {}
  end

  def ext(input_ext)
    raise NotImplementedError
  end

  def compile(input)
    raise NotImplementedError
  end
end
