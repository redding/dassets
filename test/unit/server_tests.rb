# frozen_string_literal: true

require "assert"
require "dassets/server"

class Dassets::Server
  class UnitTests < Assert::Context
    desc "Dassets::Server"
    subject{ Dassets::Server.new("test rack app") }

    should have_imeths :call, :call!
  end
end
