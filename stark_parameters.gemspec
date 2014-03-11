# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stark_parameters/version'

Gem::Specification.new do |gem|
  gem.name          = "stark parameters"
  gem.version       = StarkParameters::VERSION
  gem.authors       = ["rylev"]
  gem.email         = ["ryan.levick@gmail.com"]
  gem.description   = %q{Making Strong Parameters Stark}
  gem.summary       = %q{Wraps Strong Parameters with additonal functionality}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'strong_parameters'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end