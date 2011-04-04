require 'rack/request'
require 'rack/mock'

require_relative '../spec_helper'
require 'lib/ananke/dsl'
require 'spec/lib/test_resource'

describe Ananke::DSL, "#resource" do

  it "should create a resource based on name, class, method and type" do
    Ananke::Base.reset!
    Ananke::Base.resources.empty?.should == true

    resource :test, :class => Test, :method => :get_basic, :type => :get
    Ananke::Base.routes['/test/get_basic'].should == {
          :class => Test,
          :method => :get_basic,
          :type => :get,
          :route => '/test/get_basic'
      }
  end

  it "should create a resource based on name, class and method" do
    Ananke::Base.reset!
    Ananke::Base.resources.empty?.should == true

    resource :test, :class => Test, :method => :get_basic
    Ananke::Base.routes['/test/get_basic'].should == {
          :class => Test,
          :method => :get_basic,
          :type => :get,
          :route => '/test/get_basic'
      }
  end

  it "should create a resource based on name and class" do
    Ananke::Base.reset!
    Ananke::Base.resources.empty?.should == true

    resource :test, :class => Test
    Ananke::Base.routes['/test/get_basic'].should == {
          :class => Test,
          :method => :get_basic,
          :type => :get,
          :route => '/test/get_basic'
      }
    Ananke::Base.routes['/test/post_params'].should == {
          :class => Test,
          :method => :post_params,
          :type => :post,
          :route => '/test/post_params'
      }
  end

end
