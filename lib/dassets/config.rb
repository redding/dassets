require 'pathname'
require 'dassets/cache'
require 'dassets/file_store'
require 'dassets/source'

module Dassets

  class Config

    attr_reader :sources, :combinations

    def initialize
      super
      self.reset
      @content_cache     = Dassets::Cache::NoCache.new
      @fingerprint_cache = Dassets::Cache::NoCache.new
      @file_store        = FileStore::NullStore.new
    end

    def reset
      @sources      = []
      @combinations = Hash.new{ |h, k| [k] } # digest pass-thru if none defined
    end

    def base_url(value = nil)
      set_base_url(value) if !value.nil?
      @base_url
    end

    def set_base_url(value)
      @base_url = value
    end

    def file_store(value = nil)
      if !value.nil?
        @file_store = (value.kind_of?(FileStore) ? value : FileStore.new(value))
      end
      @file_store
    end

    def content_cache(cache = nil)
      @content_cache = cache if !cache.nil?
      @content_cache
    end

    def fingerprint_cache(cache = nil)
      @fingerprint_cache = cache if !cache.nil?
      @fingerprint_cache
    end

    def source(path, &block)
      @sources << Source.new(path).tap{ |s| block.call(s) if block }
    end

    def combination(key_digest_path, value_digest_paths)
      @combinations[key_digest_path.to_s] = [*value_digest_paths]
    end

    def combination?(key_digest_path)
      # a digest path is only considered a combination is it is not the default
      # pass-thru above
      @combinations[key_digest_path.to_s] != [key_digest_path]
    end

  end

end
