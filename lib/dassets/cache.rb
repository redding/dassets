module Dassets; end
module Dassets::Cache

  class MemCache
    require 'thread'

    # this is a thread-safe in-memory cache

    def initialize
      @hash = {}
      @write_mutex = ::Mutex.new
    end

    def keys
      @hash.keys
    end

    def [](key)
      @hash[key]
    end

    def []=(key, value)
      @write_mutex.synchronize{ @hash[key] = value }
    end

  end

  class NoCache

    # This is a no-op cache object.  This is the default cache in use and "turns
    # off caching.

    def keys
      []
    end

    def [](key)
    end

    def []=(key, value)
    end

  end

end
