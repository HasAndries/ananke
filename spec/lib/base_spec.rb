require 'rack/request'
require 'rack/mock'
require './lib/ananke/base'
require './lib/ananke/resource'
require './spec/spec_helper'
require './spec/lib/test_resource'

include Ananke

describe Ananke::Base, "#add_resource" do

  it "should add a resource to the resources collection for later use" do
    Base.resources.empty?.should == true
    Base.add_resource Resource.new :resource_name => :test
    Base.resources.empty?.should == false
    Base.resources[:test].nil?.should == false
  end

  it "should identify add resource's routes to a collection" do
    Base.routes.empty?.should == true
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :get_basic,
                :type => :post
    end
    Base.add_resource resource
    Base.routes.empty?.should == false
    Base.routes['/test/get_basic'].should == {
          :class => Test,
          :method => :get_basic,
          :type => :post,
          :route => '/test/get_basic'
      }
  end

end

describe Ananke::Base, "#route!" do

  it "should do the calls that correspond to a valid GET input request" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :get_basic
    end
    Base.add_resource resource
    request = Rack::Request.new Rack::MockRequest.env_for("/test/get_basic", :method => "GET")
    Base.route!(request).should == 'basic'
  end

  it "should do the calls that correspond to a valid POST input request" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :post_basic,
                :type => :post
    end
    Base.add_resource resource

    request = Rack::Request.new Rack::MockRequest.env_for("/test/post_basic", :method => "POST")
    Base.route!(request).should == 'basic'
  end

  it "should raise error for an invalid input request" do
    request = Rack::Request.new Rack::MockRequest.env_for("/some_invalid_call")
    lambda {Base.route!(request)}.should raise_error(MissingRouteError)
  end

  it "should do a call with parameters available in the request" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :post_params,
                :type => :post
    end
    Base.add_resource resource

    request = Rack::Request.new Rack::MockRequest.env_for("/test/post_params?q1=1&q2=2", :method => "POST", :input => 'f1=1&f2=2')
    Base.route!(request).should == 'params'
  end

  it "should raise error for a request that doesn't have all required params for a call" do
    resource = Resource.new :resource_name => :test do |r|
      r.add_call :class => Test,
                :method => :post_params,
                :type => :post
    end
    Base.add_resource resource

    request = Rack::Request.new Rack::MockRequest.env_for("/test/post_params?q1=1&q2=2", :method => "POST")
    lambda{ Base.route!(request) }.should raise_error(MissingParameterError)
  end

end

describe Ananke::Base, "#reset!" do

  it "should reset resources" do
    Base.add_resource Resource.new :resource_name => :test
    Base.resources.empty?.should == false
    Base.reset!
    Base.resources.empty?.should == true
  end

end