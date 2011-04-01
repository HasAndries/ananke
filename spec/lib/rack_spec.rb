require_relative '../spec_helper'
require 'lib/ananke/base'
require 'lib/ananke/resource'
require 'spec/lib/test_resource'

include Ananke

describe Ananke::Base, "#call" do

  it "should respond with a 404 if a resource is not found" do
    env = Rack::MockRequest.env_for("/not_found")
    status = Ananke::Base.new().call(env)[0]
    status.should == 404
  end

  it "should respond with a 500 if a generic error is raised" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :error_generic
    end
    Base.add_resource resource

    env = Rack::MockRequest.env_for("/test/error_generic")
    status = Ananke::Base.new().call(env)[0]
    status.should == 500
  end

  it "should respond with a 501 if a specific error is raised" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :error_501
    end
    Base.add_resource resource

    env = Rack::MockRequest.env_for("/test/error_501")
    status = Ananke::Base.new().call(env)[0]
    status.should == 501
  end

  it "should respond with a 500 if an unhandled error is raised" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :error_unhandled
    end
    Base.add_resource resource

    env = Rack::MockRequest.env_for("/test/error_unhandled")
    status = Ananke::Base.new().call(env)[0]
    status.should == 500
  end

end