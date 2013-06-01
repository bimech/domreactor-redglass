Gem::Specification.new do |s|
  s.name          = 'domreactor-redglass'
  s.version       = '0.0.2'
  s.date          = '2013-05-31'
  s.summary       = 'DomReactor plugin for RedGlass.'
  s.description   = 'Send RedGlass page archives to DomReactor for automated layout analysis.'
  s.authors       = ["Frank O'Hara"]
  s.email         = ["frankj.ohara@gmail.com"]
  s.files         = Dir.glob("{lib}/**/*")
  s.homepage      = 'https://github.com/bimech/domreactor-redglass'
  s.add_dependency 'rest-client'
  s.add_dependency 'json'
  s.add_dependency 'rubyzip'
  s.add_dependency 'red-glass', '>= 0.1.1'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'selenium-webdriver'
end
