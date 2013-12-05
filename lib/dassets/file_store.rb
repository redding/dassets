require 'thread'

module Dassets

  class FileStore
    attr_reader :root

    def initialize(root)
      @root = root
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

    class NullStore < FileStore
      def initialize
        super('')
      end

      def save(url, &block)
        store_path(url) # no-op, just return the store path like the base does
      end
    end

  end

end
