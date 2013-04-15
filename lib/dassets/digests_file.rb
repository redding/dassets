require 'multi_json'

module Dassets; end
class Dassets::DigestsFile

  attr_reader :path

  def initialize(file_path)
    @path = file_path
    @hash = MultiJson.decode(File.read(file_path))
  end

  def [](*args);  @hash.send('[]', *args);  end
  def []=(*args); @hash.send('[]=', *args); end
  def index_of(*args); @hash.send('index_of', *args); end

  def keys;   @hash.keys;   end
  def values; @hash.values; end
  def empty?; @hash.empty?; end

  def to_hash
    Hash.new.tap do |to_hash|
      @hash.each{ |k, v| to_hash[k] = v }
    end
  end

  def save!
    File.open(@path, 'w'){ |f| f.write(MultiJson.encode(@hash, :pretty => true)) }
  end

end
