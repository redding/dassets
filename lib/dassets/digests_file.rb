module Dassets; end
class Dassets::DigestsFile

  attr_reader :path

  def initialize(file_path)
    @path, @hash = file_path, decode(file_path)
  end

  def [](*args);  @hash.send('[]', *args);  end
  def []=(*args); @hash.send('[]=', *args); end
  def delete(*args); @hash.delete(*args);   end

  def each(*args, &block); @hash.each(*args, &block); end

  def keys;   @hash.keys;   end
  def values; @hash.values; end
  def empty?; @hash.empty?; end

  def asset_files
    @hash.map{ |path, md5| Dassets::AssetFile.new(path, md5) }
  end

  def to_hash
    Hash.new.tap do |to_hash|
      @hash.each{ |k, v| to_hash[k] = v }
    end
  end

  def save!
    encode(@hash, @path)
  end

  private

  def decode(file_path)
    Hash.new.tap do |h|
      File.open(file_path, 'r').each_line do |l|
        path, md5 = l.split(','); path ||= ''; path.strip!; md5 ||= ''; md5.strip!
        h[path] = md5 if !path.empty?
      end
    end
  end

  def encode(hash, file_path)
    File.open(file_path, 'w') do |f|
      hash.keys.sort.each{ |path| f.write("#{path.strip},#{hash[path].strip}\n") }
    end
  end

end
