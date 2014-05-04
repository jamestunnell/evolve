# -*- encoding: utf-8 -*-

require File.expand_path('../lib/genetic_algorithm/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "genetic_algorithm"
  gem.version       = GeneticAlgorithm::VERSION
  gem.summary       = %q{Basic genetic algorithm framework, suitable for most experiments.}
  gem.description   = %q{Basic genetic algorithm framework, suitable for most experiments.}
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@gmail.com"
  gem.homepage      = "https://rubygems.org/gems/genetic_algorithm"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'yard', '~> 0.8'
end
