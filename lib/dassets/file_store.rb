require 'thread'
require 'dassets/root_path'

module Dassets; end
class Dassets::FileStore
  attr_reader :root

  def initialize(root)
    @root = Dassets::RootPath.new(root)
    @save_mutex = ::Mutex.new
  end

  def save(url, &block)
    @save_mutex.synchronize do
      store_path(url).tap do |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w"){ |f| f.write(block.call) }
      end
    end
  end

  def store_path(url)
    File.join(@root, url)
  end

end

class Dassets::NullFileStore < Dassets::FileStore
  def initialize
    super('')
  end

  def save(url, &block)
    store_path(url) # no-op, just return the store path like the base does
  end
end
