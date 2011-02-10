#=========================CODE COVERAGE========================
require './spec/cov_adapter'
SimpleCov.start 'cov'

#===========================REQUIRES===========================
require 'colored'
require 'json'
require 'rack'
require 'rspec'
require 'rack/test'
require './lib/ananke'

extend Colored

#==================SETUP TEST ENVIRONMENT======================
ENV['RACK_ENV'] = 'test'

Ananke.set :output, false
Ananke.set :info, true
Ananke.set :warning, true
Ananke.set :error, true

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))

#==================FOR DUMPING HTTP REQUESTS===================
require './spec/dumping'
clear_dump