# -*- encoding: utf-8 -*-
require File.expand_path('../lib/commonjs_deps/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniel Gregoire"]
  gem.email         = ["daniel.l.gregoire@gmail.com"]
  gem.description   = "Analyze a JavaScript codebase and generate a dependency graph from 'require' statements."
  gem.summary       = "Analyze CommonJS dependency graphs for JavaScript code bases."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "commonjs_deps"
  gem.require_paths = ["lib"]
  gem.version       = CommonjsDeps::VERSION
  # Runtime Dependencies
  gem.add_dependency('ruby-graphviz', '~> 1.0.8')
  gem.add_dependency('ruby-progressbar', '~> 1.0.2')
  # Development Dependencies
  gem.add_development_dependency('pry', '~> 0.9.10')
end
