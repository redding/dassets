# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dassets/version"

Gem::Specification.new do |gem|
  gem.name        = "dassets"
  gem.version     = Dassets::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = %q{Digested asset files}
  gem.description = %q{Digest and serve HTML asset files}
  gem.homepage    = "http://github.com/redding/dassets"
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.5"

  gem.add_development_dependency("assert",           ["~> 2.18.4"])
  gem.add_development_dependency('assert-rack-test', ["~> 1.0.5"])
  gem.add_development_dependency("sinatra",          ["~> 2.1"])

  gem.add_dependency("rack", ["~> 2.1"])
end
