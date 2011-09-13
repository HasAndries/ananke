# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sinatra/version"

Gem::Specification.new do |s|
  s.name        = "ananke"
  s.version     = Ananke::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andries Coetzee"]
  s.email       = ["andriesc@lime-square.net"]
  s.homepage    = "http://github.com/hasandries/ananke"
  s.summary     = "The Awesome ReST framework"
  s.description = "Ananke enables a new kind of ReST implementation"

  s.required_rubygems_version = "~> 1.8.10"

  s.add_dependency "colored", '~>1.2'
  s.add_dependency "json", '~>1.6.0'
  s.add_dependency "sinatra", '~>1.2.6'
  
  s.add_development_dependency "rack-test", '~>0.6.1'
  s.add_development_dependency "rake", '~>0.9.2'
  s.add_development_dependency "rspec", '~>2.6.0'
  s.add_development_dependency "simplecov", '~>0.5.2'

  s.files        = Dir.glob("lib/**/*") + %w(README.rdoc)
  s.require_path = 'lib'
end
