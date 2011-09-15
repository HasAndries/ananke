require 'rack/request'
require 'rack/mock'

require_relative '../spec_helper'
require 'lib/sinatra/ananke'

describe Sinatra::Ananke, '#resource' do
  before(:all) {Sinatra::Base.reset!}
  
  it "should define a new Sinatra Base Class and setup a Resource" do
    resource :basic, :id => :basic_id, :link_self => true, :link_to => [:not_basic]

    Basic.respond_to?(:new).should == true
    Basic.resource_name.should == :basic
    Basic.resource_id.should == :basic_id
    Basic.resource_link_self?.should == true
    Basic.resource_link_to.should == [:not_basic]
  end

  it "should be able to define a get_resource" do
    resource :basic, :id => :basic_id do
      get!(:normal) { |basic_id| basic_id.should == 1}
    end
    env = Rack::MockRequest.env_for("/basic/normal/1")
    status, header, body = Basic.new.call(env)
    status.should == 200
    body[0].should == '[true]'
  end

  it "should be able to define a one_resource" do
    resource :basic, :id => :basic_id do
      one { |basic_id| basic_id.should == 1}
    end
    env = Rack::MockRequest.env_for("/basic/1")
    status, header, body = Basic.new.call(env)
    status.should == 200
    body[0].should == '[true]'
  end

  it "should be able to define a all_resource" do
    resource :basic do
      all { [1,2]}
    end
    env = Rack::MockRequest.env_for("/basic")
    status, header, body = Basic.new.call(env)
    status.should == 200
    body[0].should == '[1,2]'
  end

  it "should be able to define an add_resource" do
    resource :basic do
      add { |name| name.should == 'Lucky'}
    end
    env = Rack::MockRequest.env_for("/basic?name=Lucky", "REQUEST_METHOD" => "POST")
    status, header, body = Basic.new.call(env)
    status.should == 200
  end

  it "should be able to define an edit_resource" do
    resource :basic, :id => :basic_id do
      edit {|basic_id, name| basic_id.should == 1; name.should == 'Lucky'}
    end
    env = Rack::MockRequest.env_for("/basic/1?name=Lucky", "REQUEST_METHOD" => "PUT")
    status, header, body = Basic.new.call(env)
    status.should == 200
  end

  it "should be able to define a trash_resource" do
    resource :basic, :id => :basic_id do
      trash { |basic_id| basic_id.should == 1}
    end
    env = Rack::MockRequest.env_for("/basic/1", "REQUEST_METHOD" => "DELETE")
    status, header, body = Basic.new.call(env)
    status.should == 200
  end

  it "should define a resource within the calling module" do
    module Some
      resource :oldman do
        all { 'some data'}
      end
    end
    Some.const_get('Oldman').nil?.should == false
    env = Rack::MockRequest.env_for("/oldman")
    status, header, body = Some::Oldman.new.call(env)
    status.should == 200
    body[0].should == '["some data"]'
  end

  it "should define a resource within a specified module using a symbol" do
    resource :specified, :module => :test1 do
      all { 'some data'}
    end
    resource :outside do
      all { 'some data'}
    end
    Test1.constants.include?(:Specified).should == true
    Test1.constants.include?(:Outside).should == false
  end

  it "should define a resource within a specified module using a string" do
    resource :specified, :module => 'Test2' do
      all { 'some data'}
    end
    Test2.constants.include?(:Specified).should == true
  end

  it "should define a resource within a specified module using a module" do
    module Test3 end
    resource :specified, :module => Test3 do
      all { 'some data'}
    end
    Test3.constants.include?(:Specified).should == true
  end

  it "should define a resource within a Globally specified module" do
    Sinatra::Ananke.resource_module = :test1
    resource :global do
      all { 'some data'}
    end
    Test1.constants.include?(:Global).should == true
  end
  
end