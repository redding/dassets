require 'dassets'

module Dassets; end
class Dassets::Runner
  UnknownCmdError = Class.new(ArgumentError)
  CmdError = Class.new(RuntimeError)
  CmdFail = Class.new(RuntimeError)

  attr_reader :cmd_name, :cmd_args, :opts

  def initialize(args, opts)
    @opts = opts
    @cmd_name = args.shift || ""
    @cmd_args = args
  end

  def run
    Dassets.init

    case @cmd_name
    when 'digest'
      require 'dassets/runner/digest_command'
      DigestCommand.new(@cmd_args).run
    when 'cache'
      require 'dassets/runner/cache_command'
      CacheCommand.new(@cmd_args.first).run
    when 'null'
      NullCommand.new.run
    else
      raise UnknownCmdError, "unknown command `#{@cmd_name}`"
    end
  end

  class NullCommand
    def run
      # if this was a real command it would do something here
    end
  end

end
