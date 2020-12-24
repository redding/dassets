# frozen_string_literal: true

require "thread"

module Dassets; end

# This is a thread-safe in-memory cache.
class Dassets::MemCache
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

# This is a no-op cache object. This is the default cache in use and "turns
# off caching.
class Dassets::NoCache
  def keys
    []
  end

  def [](key)
  end

  def []=(key, value)
  end
end
