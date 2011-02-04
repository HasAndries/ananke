#=========================CODE COVERAGE========================
require './spec/cov_adapter'
SimpleCov.start 'cov'

#===========================REQUIRES===========================
require 'colored'
require 'json'
require 'rack'
require 'rspec'
require 'rack/test'

extend Colored

#==================SETUP TEST ENVIRONMENT======================
ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))
