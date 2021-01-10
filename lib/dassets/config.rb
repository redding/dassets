# frozen_string_literal: true

require "pathname"
require "dassets/cache"
require "dassets/file_store"
require "dassets/source"

module Dassets; end

class Dassets::Config
  attr_reader :sources, :combinations

  def initialize
    super
    reset

    @content_cache     = Dassets::NoCache.new
    @fingerprint_cache = Dassets::NoCache.new
    @file_store        = Dassets::NullFileStore.new
  end

  def reset
    @sources      = []
    @combinations = Hash.new{ |_h, k| [k] } # digest pass-thru if none defined
    @file_store   = Dassets::NullFileStore.new
  end

  def base_url(value = nil)
    set_base_url(value) unless value.nil?
    @base_url
  end

  def set_base_url(value)
    @base_url = value
  end

  def file_store(value = nil)
    unless value.nil?
      @file_store =
        if value.is_a?(Dassets::FileStore)
          value
        else
          Dassets::FileStore.new(value)
        end
    end
    @file_store
  end

  def content_cache(cache = nil)
    @content_cache = cache unless cache.nil?
    @content_cache
  end

  def fingerprint_cache(cache = nil)
    @fingerprint_cache = cache unless cache.nil?
    @fingerprint_cache
  end

  def source(path, &block)
    @sources << Dassets::Source.new(path).tap{ |s| block.call(s) if block }
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
