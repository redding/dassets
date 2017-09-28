require 'dassets/version'
require 'dassets/asset_file'
require 'dassets/config'
require 'dassets/source_file'

module Dassets

  def self.config; @config ||= Config.new; end
  def self.configure(&block)
    block.call(self.config)
  end

  def self.init
    @asset_files  ||= {}
    @source_files   = SourceFiles.new(self.config.sources)
  end

  def self.reset
    @asset_files = {}
    self.config.reset
  end

  def self.asset_file(digest_path)
    @asset_files[digest_path] ||= AssetFile.new(digest_path)
  end

  def self.[](digest_path)
    self.asset_file(digest_path).tap do |af|
      if af.fingerprint.nil?
        msg = "error digesting `#{digest_path}`.\n\nMake sure Dassets has " \
              "either a combination or source file for this digest path. If " \
              "this path is for a combination, make sure Dassets has either " \
              "a combination or source file for each digest path of the " \
              "combination.\n\n"

        msg << "\nCombination digest paths:"
        msg << (Dassets.combinations.keys.empty? ? " (none)\n\n" : "\n\n")
        Dassets.combinations.keys.sort.each do |key|
          bullet = "#{key} => "
          values = Dassets.combinations[key].sort
          msg << (
            ["#{bullet}#{values.first}"] +
            (values[1..-1] || []).map{ |v| "#{' '*bullet.size}#{v}" }
          ).join("\n")
          msg << "\n\n"
        end

        msg << "\nSource file digest paths:"
        msg << (Dassets.source_files.keys.empty? ? " (none)\n\n" : "\n\n")
        msg << Dassets.source_files.keys.sort.join("\n")

        raise AssetFileError, msg
      end
    end
  end

  def self.source_files
    @source_files
  end

  def self.combinations
    self.config.combinations
  end

  module SourceFiles

    def self.new(sources)
      # use a hash to store the source files so in the case two source files
      # have the same digest path, the last one *should* be correct since it
      # was last to be configured
      sources.inject({}) do |hash, source|
        source.files.each do |file_path|
          s = SourceFile.new(file_path)
          hash[s.digest_path] = s
        end
        hash
      end
    end

  end

  AssetFileError = Class.new(RuntimeError)

end

Dassets.init
