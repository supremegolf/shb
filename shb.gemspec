# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shb/version'

Gem::Specification.new do |gem|
  gem.name          = "shb"
  gem.version       = Shb::VERSION
  gem.authors       = ["Philip Hallstrom"]
  gem.email         = ["philip@supremegolf.com"]
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/supremegolf/shb"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport', '>= 4.0'
  gem.add_dependency 'httparty',      '>= 0.13.1'
  gem.add_dependency 'nokogiri',      '>= 1.6.3.1'
  gem.add_dependency 'json'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'
end
