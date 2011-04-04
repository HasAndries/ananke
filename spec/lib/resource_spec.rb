require_relative '../spec_helper'
require 'spec/lib/test_resource'
require 'lib/ananke/resource'

describe Ananke::Resource, "#initialize" do
  it "should create a basic Resource" do
    r = Ananke::Resource.new :resource_name => :test
    
    r.resource_name.should == :test
    r.calls.empty?.should == true
  end
end

describe Ananke::Resource, "#add_call" do
  it "should add a basic call to a Resource" do
    r = Ananke::Resource.new :resource_name => :test

    r.add_call :class => Test,
                :method => :get_basic

    r.calls.empty?.should == false
    r.calls[0][:class].should == Test
    r.calls[0][:method].should == :get_basic
    r.calls[0][:type].should == :get
    r.calls[0][:route].should == "/test/get_basic"
  end
  
  it "should add a basic call to a Resource with a specific Http Call Type" do
    r = Ananke::Resource.new :resource_name => :test

    r.add_call :class => Test,
                :method => :post_basic,
                :type => :post

    r.calls[0][:type].should == :post
  end

  it "should be able to use the method in a call" do
    r = Ananke::Resource.new :resource_name => :test

    r.add_call :class => Test,
                :method => :get_basic

    r.calls[0][:class].new.send(r.calls[0][:method]).should == 'basic'
  end

end

#describe Ananke::Resource, "#link_self" do
#
#  it "should provide a relative link to the resource" do
#    r = Ananke::Resource.new :resource_name => :test
#
#    r.add_call :class => Test,
#                :method => :get_basic
#
#    r.link_self.should == "/test/"
#
#  end
#
#end