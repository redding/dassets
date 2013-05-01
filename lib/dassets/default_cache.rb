require 'thread'

# this is a thread-safe in-memory cache for use with the `SourceCache` that
# only caches source fingerprint keys.  there are a few reasons for using this
# as the "default":
# * source fingerprints are accessed more frequently than contents (ie hrefs,
#   urls, etc) so caching them can have nice affects on performance.  Plus it
#   seems silly to have to compile the source file everytime you want to get its
#   href so you can link it in.
# * fingerprints have a much smaller data size so won't overly bloat memory.

class Dassets::DefaultCache

  def initialize
    @hash = {}
    @write_mutex = ::Mutex.new
  end

  def keys;    @hash.keys; end
  def [](key); @hash[key]; end

  def []=(key, value)
    @write_mutex.synchronize do
      @hash[key] = value if key =~ /-- fingerprint$/ # only write fingerprint keys
    end
  end

end

