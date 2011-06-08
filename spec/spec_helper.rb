$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))
#=========================CODE COVERAGE========================
require 'simplecov'
SimpleCov.start do
  coverage_dir 'public/coverage'

  add_filter '/config/'
  add_filter '/dump/'
  add_filter '/public/'
  add_filter '/spec/'
  add_filter '/tmp/'
  add_filter '/views/'

end

#===========================REQUIRES===========================
require 'colored'
require 'json'
require 'rack'
require 'rspec'
require 'rack/test'

extend Colored

#==================SETUP TEST ENVIRONMENT======================
ENV['RACK_ENV'] = 'test'

#==================RACK TEST===================================
include Rack::Test::Methods