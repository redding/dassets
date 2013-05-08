# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

# require pry for debugging (`binding.pry`)
require 'pry'

require 'pathname'
TEST_SUPPORT_PATH = Pathname.new(File.expand_path('../support', __FILE__))

ENV['DASSETS_TEST_MODE']   = 'yes'
ENV['DASSETS_ASSETS_FILE'] = 'test/support/config/assets'
require 'dassets'
Dassets.init
