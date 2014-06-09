require 'assert'
require 'dassets/server'

class Dassets::Server

  class UnitTests < Assert::Context
    desc "Dassets::Server"
    setup do
      @server = Dassets::Server.new('a rack app goes here')
    end
    subject{ @server }

    should have_imeths :call, :call!

  end

end
