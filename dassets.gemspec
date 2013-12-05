# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dassets/version"

Gem::Specification.new do |gem|
  gem.name        = "dassets"
  gem.version     = Dassets::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.description = %q{Digest and serve HTML asset files}
  gem.summary     = %q{Digested asset files}
  gem.homepage    = "http://github.com/redding/dassets"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.4"])
  gem.add_development_dependency('assert-rack-test', ["~> 1.0"])
  gem.add_development_dependency("sinatra", ["~> 1.4"])


  gem.add_dependency('ns-options', ["~> 1.1"])
  gem.add_dependency("rack",       ["~> 1.0"])

end
