require 'digest/md5'
require 'dassets'

module Dassets

  class SourceFile

    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
      @ext_list = File.basename(@file_path).split('.').reverse
    end

    def exists?
      File.file?(@file_path)
    end

    def digest
      return if !self.exists?

      Dassets::AssetFile.new(self.digest_path, self.fingerprint).tap do |asset_file|
        File.open(asset_file.output_path, 'w'){ |f| f.write(self.compiled) }
        Dassets.digests[self.digest_path] = self.fingerprint
        Dassets.digests.save!
      end
    end

    def digest_path
      @digest_path ||= begin
        digest_basename = @ext_list.inject([]) do |digest_ext_list, ext|
          digest_ext_list << Dassets.config.engines[ext].ext(ext)
        end.reject{ |e| e.empty? }.reverse.join('.')

        File.join([
          digest_dirname(@file_path, Dassets.config.source_path),
          digest_basename
        ].reject{ |p| p.empty? })
      end
    end

    def compiled
      @compiled ||= @ext_list.inject(read_file(@file_path)) do |content, ext|
        Dassets.config.engines[ext].compile(content)
      end
    end

    def fingerprint
      @fingerprint ||= Digest::MD5.new.hexdigest(self.compiled)
    end

    private

    def digest_dirname(file_path, source_path)
      slash_path(File.dirname(file_path)).sub(slash_path(source_path), '')
    end

    def slash_path(path)
      File.join(path, '')
    end

    def read_file(path)
      File.send(File.respond_to?(:binread) ? :binread : :read, path.to_s)
    end

  end

end
