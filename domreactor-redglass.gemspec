# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domreactor-redglass/version'

Gem::Specification.new do |s|
  s.name          = 'domreactor-redglass'
  s.version       = DomReactorRedGlass::VERSION
  s.date          = '2013-10-31'
  s.summary       = 'DomReactor plugin for RedGlass.'
  s.description   = 'Send RedGlass page archives to DomReactor for automated layout analysis.'
  s.authors       = ["Frank O'Hara", "Chris Lamb"]
  s.email         = ["frankj.ohara@gmail.com", "lamb.chrisr@gmail.com"]
  s.homepage      = 'https://github.com/bimech/domreactor-redglass'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'rest-client'
  s.add_dependency 'json'
  s.add_dependency 'rubyzip'
  s.add_dependency 'red-glass', '>= 0.1.1'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.14.0"
  s.add_development_dependency 'selenium-webdriver'
end
