require 'sinatra/base'

class SinatraApp < Sinatra::Base

  configure do
    set :root, File.expand_path('..', __FILE__)
    set :public_dir, File.expand_path('./app_public', __FILE__)
  end

end
