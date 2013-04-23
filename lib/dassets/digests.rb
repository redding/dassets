require 'dassets/asset_file'

module Dassets

  class Digests

    attr_reader :file_path

    def initialize(file_path)
      @file_path, @hash = file_path, decode(file_path)
    end

    def [](*args);  @hash.send('[]', *args);  end
    def []=(*args); @hash.send('[]=', *args); end
    def delete(*args); @hash.delete(*args);   end

    def paths
      @hash.keys
    end

    # TODO: still needed??
    def asset_files
      @hash.map{ |path, md5| Dassets::AssetFile.new(path, md5) }
    end

    # TODO: still needed??
    def asset_file(path)
      Dassets::AssetFile.new(path, @hash[path] || '')
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
