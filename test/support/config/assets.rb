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
  c.source TEST_SUPPORT_PATH.join("app/assets")

  c.engine 'dumb', @dumb_engine
  c.engine 'useless', @useless_engine
  c.cache = nil # use no cache

end
