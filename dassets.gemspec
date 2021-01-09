# -*- encoding: utf-8 -*-
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dassets/version"

Gem::Specification.new do |gem|
  gem.name        = "dassets"
  gem.version     = Dassets::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = "Digested asset files"
  gem.description = "Digest and serve HTML asset files"
  gem.homepage    = "http://github.com/redding/dassets"
  gem.license     = "MIT"

  gem.files = `git ls-files | grep "^[^.]"`.split($INPUT_RECORD_SEPARATOR)

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.5"

  gem.add_development_dependency("much-style-guide", ["~> 0.6.0"])
  gem.add_development_dependency("assert",           ["~> 2.19.3"])
  gem.add_development_dependency("assert-rack-test", ["~> 1.1.1"])
  gem.add_development_dependency("sinatra",          ["~> 2.1"])

  gem.add_dependency("rack", ["~> 2.1"])
end
