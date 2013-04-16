require 'dassets'
require 'dassets/runner/digest_command'

module Dassets; end
class Dassets::Runner
  UnknownCmdError = Class.new(ArgumentError)
  CmdError = Class.new(RuntimeError)
  CmdFail = Class.new(RuntimeError)

  attr_reader :cmd_name, :cmd_args, :opts, :root_path

  def initialize(args, opts)
    @opts = opts
    @cmd_name = args.shift || ""
    @cmd_args = args
    @root_path = @opts.delete('root_path') || Dir.pwd
  end

  def run
    DassetsConfigFile.new(@root_path).require_if_exists

    case @cmd_name
    when 'digest'
      DigestCommand.new(@cmd_args).run
    when 'cache'
      CacheCommand.new(@cmd_args.first).run
    when 'null'
      NullCommand.new.run
    else
      raise UnknownCmdError, "unknown command `#{@cmd_name}`"
    end
  end

  class DassetsConfigFile
    PATH = 'config/dassets.rb'
    def initialize(root_path)
      @path = File.join(root_path, PATH)
    end

    def require_if_exists
      require @path.to_s if File.exists?(@path.to_s)
    end
  end

  class NullCommand
    def run
      # if this was a real command it would do something here
    end
  end

end
