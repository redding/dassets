# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

# require pry for debugging (`binding.pry`)
require 'pry'

require 'test/support/factory'

# 1.8.7 backfills

# Array#sample
if !(a = Array.new).respond_to?(:sample) && a.respond_to?(:choice)
  class Array
    alias_method :sample, :choice
  end
end

require 'pathname'
TEST_SUPPORT_PATH = Pathname.new(File.expand_path('../support', __FILE__))

ENV['DASSETS_TEST_MODE']   = 'yes'

require 'dassets'

@dumb_engine = Class.new(Dassets::Engine) do
  def ext(in_ext); ''; end
  def compile(input); "#{input}\nDUMB"; end
end
@useless_engine = Class.new(Dassets::Engine) do
  def ext(in_ext); 'no-use'; end
  def compile(input); "#{input}\nUSELESS"; end
end

Dassets.configure do |c|
  c.source TEST_SUPPORT_PATH.join("app/assets") do |s|
    s.engine 'dumb', @dumb_engine
    s.engine 'useless', @useless_engine
    s.response_headers[Factory.string] = Factory.string
  end
end
