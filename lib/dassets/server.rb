# frozen_string_literal: true

require "dassets/server/request"
require "dassets/server/response"

# Rack middleware for serving Dassets asset files

module Dassets; end

class Dassets::Server
  def initialize(app)
    @app = app
  end

  # The Rack call interface. The receiver acts as a prototype and runs
  # each request in a clone object unless the +rack.run_once+ variable is
  # set in the environment. Ripped from:
  # http://github.com/rtomayko/rack-cache/blob/master/lib/rack/cache/context.rb
  def call(env)
    if env["rack.run_once"]
      call! env
    else
      clone.call! env
    end
  end

  # The real Rack call interface.
  # if an asset file is being requested, this is an endpoint - otherwise, call
  # on up to the app as normal
  def call!(env)
    if (request = Request.new(env)).for_asset_file?
      Response.new(env, request.asset_file).to_rack
    else
      @app.call(env)
    end
  end
end
