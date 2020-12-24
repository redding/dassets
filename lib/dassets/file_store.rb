require "thread"

module Dassets; end

class Dassets::FileStore
  attr_reader :root

  def initialize(root)
    @root       = root
    @save_mutex = ::Mutex.new
  end

  def save(url_path, &block)
    @save_mutex.synchronize do
      store_path(url_path).tap { |path|
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w") { |f| f.write(block.call) }
      }
    end
  end

  def store_path(url_path)
    File.join(@root, url_path)
  end
end

class Dassets::NullFileStore < Dassets::FileStore
  def initialize
    super("")
  end

  def save(url_path, &block)
    # No-op, just return the store path like the base does.
    store_path(url_path)
  end
end
