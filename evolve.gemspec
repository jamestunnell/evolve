# -*- encoding: utf-8 -*-

require File.expand_path('../lib/evolve/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "evolve"
  gem.version       = Evolve::VERSION
  gem.summary       = %q{Basic genetic algorithm framework, suitable for most experiments.}
  gem.description   = %q{Basic genetic algorithm framework, suitable for most experiments.}
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@gmail.com"
  gem.homepage      = "https://rubygems.org/gems/evolve"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'gnuplot'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'yard', '~> 0.8'
  gem.add_development_dependency 'pry'
end
