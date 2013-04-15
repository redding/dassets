require 'dassets/version'
require 'dassets/runner'

module Dassets

  class CLI

    def self.run(*args)
      self.new.run(*args)
    end

    def initialize
      @cli = CLIRB.new do
        option 'root_path', 'root path Dassets should use (`Dir.pwd`)', {
          :abbrev => 'p', :value => String
        }
      end
    end

    def run(*args)
      begin
        @cli.parse!(args)
        Dassets::Runner.new(@cli.args, @cli.opts).run
      rescue CLIRB::HelpExit
        puts help
      rescue CLIRB::VersionExit
        puts Dassets::VERSION
      rescue Dassets::Runner::UnknownCmdError => err
        $stderr.puts "#{err.message}\n\n"
        $stderr.puts help
        exit(1)
      rescue Dassets::NotConfiguredError, Dassets::Runner::CmdError => err
        $stderr.puts "#{err.message}"
        exit(1)
      rescue Dassets::Runner::CmdFail => err
        exit(1)
      rescue CLIRB::Error => exception
        $stderr.puts "#{exception.message}\n\n"
        $stderr.puts help
        exit(1)
      rescue Exception => exception
        $stderr.puts "#{exception.class}: #{exception.message}"
        $stderr.puts exception.backtrace.join("\n")
        exit(1)
      end
      exit(0)
    end

    def help
      "Usage: dassets [options] COMMAND\n"\
      "\n"\
      "Options:"\
      "#{@cli}"
    end

  end

  class CLIRB  # Version 1.0.0, https://github.com/redding/cli.rb
    Error    = Class.new(RuntimeError);
    HelpExit = Class.new(RuntimeError); VersionExit = Class.new(RuntimeError)
    attr_reader :argv, :args, :opts, :data

    def initialize(&block)
      @options = []; instance_eval(&block) if block
      require 'optparse'
      @data, @args, @opts = [], [], {}; @parser = OptionParser.new do |p|
        p.banner = ''; @options.each do |o|
          @opts[o.name] = o.value; p.on(*o.parser_args){ |v| @opts[o.name] = v }
        end
        p.on_tail('--version', ''){ |v| raise VersionExit, v.to_s }
        p.on_tail('--help',    ''){ |v| raise HelpExit,    v.to_s }
      end
    end

    def option(*args); @options << Option.new(*args); end
    def parse!(argv)
      @args = (argv || []).dup.tap do |args_list|
        begin; @parser.parse!(args_list)
        rescue OptionParser::ParseError => err; raise Error, err.message; end
      end; @data = @args + [@opts]
    end
    def to_s; @parser.to_s; end
    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} @data=#{@data.inspect}>"
    end

    class Option
      attr_reader :name, :opt_name, :desc, :abbrev, :value, :klass, :parser_args

      def initialize(name, *args)
        settings, @desc = args.last.kind_of?(::Hash) ? args.pop : {}, args.pop || ''
        @name, @opt_name, @abbrev = parse_name_values(name, settings[:abbrev])
        @value, @klass = gvalinfo(settings[:value])
        @parser_args = if [TrueClass, FalseClass, NilClass].include?(@klass)
          ["-#{@abbrev}", "--[no-]#{@opt_name}", @desc]
        else
          ["-#{@abbrev}", "--#{@opt_name} #{@opt_name.upcase}", @klass, @desc]
        end
      end

      private

      def parse_name_values(name, custom_abbrev)
        [ (processed_name = name.to_s.strip.downcase), processed_name.gsub('_', '-'),
          custom_abbrev || processed_name.gsub(/[^a-z]/, '').chars.first || 'a'
        ]
      end
      def gvalinfo(v); v.kind_of?(Class) ? [nil,gklass(v)] : [v,gklass(v.class)]; end
      def gklass(k); k == Fixnum ? Integer : k; end
    end
  end

end
