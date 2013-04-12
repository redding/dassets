# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dassets/version"

Gem::Specification.new do |gem|
  gem.name        = "dassets"
  gem.version     = Dassets::VERSION
  gem.authors     = ["TODO: authors"]
  gem.email       = ["TODO: emails"]
  gem.description = %q{TODO: Write a gem description}
  gem.summary     = %q{TODO: Write a gem summary}
  gem.homepage    = "http://github.com/__/dassets"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert")
  # TODO: gem.add_dependency("gem-name", ["~> 0.0"])

end
