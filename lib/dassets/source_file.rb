require 'fileutils'
require 'dassets'
require 'dassets/asset_file'

module Dassets

  class SourceFile

    def self.find_by_digest_path(path)
      # look in the configured source list
      source_files = Dassets.source_list.map{ |p| self.new(p) }

      # get the last matching one (in case two source files have the same digest
      # path the last one *should* be correct since it was last to be configured)
      source_files.select{ |s| s.digest_path == path }.last || NullSourceFile.new(path)
    end

    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path.to_s
      @ext_list = File.basename(@file_path).split('.').reverse
    end

    # get the last matching one (in the case two sources with the same path are
    # configured) since we select the last matching source file (from the last
    # configured source) in `find_by_digest_path` above.
    def source
      @source ||= Dassets.config.sources.select do |source|
        @file_path =~ /^#{slash_path(source.path)}/
      end.last
    end

    def asset_file
      @asset_file ||= Dassets::AssetFile.new(self.digest_path)
    end

    def digest_path
      @digest_path ||= begin
        digest_basename = @ext_list.inject([]) do |digest_ext_list, ext|
          digest_ext_list << Dassets.config.engines[ext].ext(ext)
        end.reject(&:empty?).reverse.join('.')

        File.join([digest_dirname(@file_path), digest_basename].reject(&:empty?))
      end
    end

    def compiled
      @compiled ||= @ext_list.inject(read_file(@file_path)) do |content, ext|
        Dassets.config.engines[ext].compile(content)
      end
    end

    def exists?
      File.file?(@file_path)
    end

    def mtime
      File.mtime(@file_path)
    end

    def ==(other_source_file)
      self.file_path == other_source_file.file_path
    end

    private

    # remove the source path from the dirname (if it exists)
    def digest_dirname(file_path)
      slash_path(File.dirname(file_path)).sub(slash_path(self.source.path), '')
    end

    def slash_path(path)
      File.join(path, '')
    end

    def read_file(path)
      File.send(File.respond_to?(:binread) ? :binread : :read, path.to_s)
    end

  end

  class NullSourceFile < SourceFile
    attr_reader :file_path, :digest_path, :compiled, :fingerprint
    def initialize(digest_path)
      @file_path = ''
      @ext_list = []
      @digest_path = digest_path
    end
    def ==(other_source_file)
      self.file_path == other_source_file.file_path
    end
  end

end
