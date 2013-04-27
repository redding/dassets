module Dassets

  class Engine

    attr_reader :opts

    def initialize(opts=nil)
      @opts = opts || {}
    end

    def ext(input_ext)
      raise NotImplementedError
    end

    def compile(input)
      raise NotImplementedError
    end

  end

  class NullEngine < Engine
    def ext(input_ext)
      input_ext
    end

    def compile(input)
      input
    end
  end

end
