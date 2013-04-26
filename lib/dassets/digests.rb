require 'dassets/asset_file'

module Dassets

  class Digests

    attr_reader :file_path

    def initialize(file_path)
      @file_path, @hash = file_path, decode(file_path)
    end

    def [](*args);     @hash.send('[]', *args);  end
    def []=(*args);    @hash.send('[]=', *args); end
    def delete(*args); @hash.delete(*args);      end
    def clear(*args);  @hash.clear(*args); self  end

    def paths
      @hash.keys
    end

    def asset_files
      self.paths.map{ |path| self.asset_file(path) }
    end

    def asset_file(digest_path)
      Dassets::AssetFile.new(digest_path, @hash[digest_path] || '')
    end

    def save!
      encode(@hash, @file_path)
    end

    private

    def decode(file_path)
      Hash.new.tap do |h|
        if File.exists?(file_path)
          File.open(file_path, 'r').each_line do |l|
            path, md5 = l.split(','); path ||= ''; path.strip!; md5 ||= ''; md5.strip!
            h[path] = md5 if !path.empty?
          end
        end
      end
    end

    def encode(hash, file_path)
      File.open(file_path, 'w') do |f|
        hash.keys.sort.each{ |path| f.write("#{path.strip},#{hash[path].strip}\n") }
      end
    end

  end

  module NullDigests
    def self.new
      Digests.new('/dev/null')
    end
  end

end
