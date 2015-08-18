require 'pathname'
require 'ns-options'
require 'dassets/cache'
require 'dassets/file_store'
require 'dassets/source'

module Dassets

  class Config
    include NsOptions::Proxy

    option :file_store, FileStore, :default => proc{ FileStore::NullStore.new }
    option :cache, :default => proc{ Cache::NoCache.new }

    attr_reader :sources, :combinations

    def initialize
      super
      @sources = []
      @combinations = Hash.new{ |h, k| [k] } # digest pass-thru if none defined
    end

    def base_url(value = nil)
      set_base_url(value) if !value.nil?
      @base_url
    end

    def set_base_url(value)
      @base_url = value
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
