require 'rack/request'
require 'rack/mock'

require_relative '../spec_helper'
require 'lib/sinatra/ananke'

class Test < Sinatra::Base
  register Sinatra::Ananke
end
class TestResourceClass
  def zero_call; 0 end
  def one_call(id1); 1 end
  def two_call(id1,id2); 2 end
  
  def error_call; app.error 404, 'some error' end
end
class TestDirectResourceClass
  def one(id); end
  def all(); end
  def add(name); end
  def edit(id,name); end
  def trash(id); end
end

describe Sinatra::Ananke, "#make_resource" do
  before(:all) {Test.reset!}

  it "should set the resource name" do
    class Test; make_resource :test end

    Test.resource_name.should == :test
  end

  it "should add resource classes as routes" do
    class Test; make_resource :test, :classes => [TestResourceClass] end

    Test.resource_name.should == :test
    Test.routes["GET"][0][0].should match '/test/zero_call'
    Test.routes["GET"][1][0].should match '/test/one_call/:id1'
    Test.routes["POST"][0][0].should match '/test/two_call'

    env = Rack::MockRequest.env_for("/test/error_call")
    status, header, body = Test.new.call(env)
    status.should == 404
  end

  it "should add resource classes as routes, with reserved methods one,all,add,edit,delete directly mapped" do
    class Test; make_resource :test; add_class TestDirectResourceClass end

    Test.resource_name.should == :test
    Test.routes["GET"][0][0].should match '/test/:id'
    Test.routes["GET"][1][0].should match '/test'
    Test.routes["POST"][0][0].should match '/test'
    Test.routes["PUT"][0][0].should match '/test/:id'
    Test.routes["DELETE"][0][0].should match '/test/:id'
  end

  it "should remove all artifacts when calling make_resource" do
    class Test; make_resource :test end

    Test.resource_name.should       == :test
    Test.resource_id.should         == :id
    Test.resource_link_self?.should == true
    Test.resource_link_to.should    == []
    Test.routes.empty?.should       == true
  end

end

describe Sinatra::Ananke, "#get!" do
  before(:all) {class Test; make_resource :test end}

  it "should register a valid get route" do
    class Test; get!(:some){'some'} end

    Test.routes["GET"].last[0].should match '/test/some'
  end

  it "should register a valid get route and validate required parameters" do
    class Test; get!(:some_id){|key, some| key.should == 1} end

    env = Rack::MockRequest.env_for("/test/some_id?key=1&some=test")
    status, header, body = Test.new.call(env)
    status.should == 200

    env = Rack::MockRequest.env_for("/test/some_id?key=1")
    status, header, body = Test.new.call(env)
    status.should == 400
  end

  it "should return a hash as a json hash" do
    class Test; get!(:hash){ {:one => 1} } end

    env = Rack::MockRequest.env_for("/test/hash")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '{"one":1}'
  end

  it "should return an array as a json array" do
    class Test; get!(:array){ [1] } end

    env = Rack::MockRequest.env_for("/test/array")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[1]'
  end

  it "should return a value as a json array" do
    class Test; get!(:single){ 1 } end

    env = Rack::MockRequest.env_for("/test/single")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[1]'
  end

  it "should return a complex object as a json string" do
    class ComplexClass
      attr_accessor :name, :surname
      def initialize(name, surname) @name,@surname=name,surname end
    end
    class Test; get!(:complex){ ComplexClass.new('Lucky', 'Luke') } end

    env = Rack::MockRequest.env_for("/test/complex")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '{"name":"Lucky","surname":"Luke"}'
  end

  it "should return an array complex objects as a json string even if only 1 element" do
    class ComplexClass
      attr_accessor :name, :surname
      def initialize(name, surname) @name,@surname=name,surname end
    end
    class Test; get!(:complex1){ [ComplexClass.new('Lucky', 'Luke')] } end

    env = Rack::MockRequest.env_for("/test/complex1")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[{"name":"Lucky","surname":"Luke"}]'
  end

  it "should be able to use Helper functions" do
    class Test; get!(:not_found) {error 404} end

    env = Rack::MockRequest.env_for("/test/not_found")
    status, header, body = Test.new.call(env)
    status.should == 404
  end

  it "should modify the route to format {resource}/{path}/{input1} when a route only has 1 input parameter" do
    class Test; get!(:reformat) {|some_input| some_input.should == 1} end

    env = Rack::MockRequest.env_for("/test/reformat/1")
    status, header, body = Test.new.call(env)
    status.should == 200
  end

end

describe Sinatra::Ananke, "#post!" do

  it "should register a valid post route" do
    class Test; post!(:some){'some'} end

    Test.routes["POST"].last[0].should match '/test/some'
  end

end

describe Sinatra::Ananke, "#put!" do

  it "should register a valid put route" do
    class Test; put!(:some){'some'} end

    Test.routes["PUT"].last[0].should match '/test/some'
  end

end

describe Sinatra::Ananke, "#delete!" do

  it "should register a valid put route" do
    class Test; delete!(:some){'some'} end

    Test.routes["DELETE"].last[0].should match '/test/some'
  end

end

describe Sinatra::Ananke, '#Linking' do

  it "should set the resource id" do
    class Test; make_resource :test, :id => :key end

    Test.resource_id.should == :key
  end

  it "should set the resource to link to itself" do
    class Test; make_resource :test, :id => :key end
    class Test; get!(:link_self){ {:key => 1, :name => 'Lucky'}} end

    Test.resource_id.should == :key
    Test.resource_link_self?.should == true

    env = Rack::MockRequest.env_for("/test/link_self")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '{"key":1,"name":"Lucky","links":[{"rel":"self","href":"/test/1"}]}'
  end

  it "should set the resource to link to another resource" do
    class Test; make_resource :test, :id => :key, :link_to => [:to], :link_self => false end
    class Test; get!(:link_to){ {:key => 1, :name => 'Lucky'}} end

    Test.resource_id.should == :key
    Test.resource_link_to.should == [:to]
    Test.resource_link_self?.should == false

    env = Rack::MockRequest.env_for("/test/link_to")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '{"key":1,"name":"Lucky","links":[{"rel":"to","href":"/to/test/1"}]}'
  end

end

describe Sinatra::Ananke, "#one" do

  it "should register a valid get route for a specific resource in the format {resource}/{id}" do
    class Test; one{|key| key.should == 1.0} end

    env = Rack::MockRequest.env_for("/test/1.0")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[true]'
  end

end

describe Sinatra::Ananke, "#all" do

  it "should register a valid get all route for all instances of a resource in the format {resource}/?" do
    class Test; all{ 'emptyness' } end

    env = Rack::MockRequest.env_for("/test")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '["emptyness"]'
  end

end

describe Sinatra::Ananke, "#add" do

  it "should register a valid get all route for all instances of a resource in the format {resource}/?" do
    class Test; add{|name| name.should == 'Lucky' } end

    env = Rack::MockRequest.env_for("/test?name=Lucky", "REQUEST_METHOD" => "POST")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[true]'
  end

end

describe Sinatra::Ananke, "#edit" do

  it "should register a valid get all route for all instances of a resource in the format {resource}/?" do
    class Test; edit{|key, name| key.should == 1; name.should == 'Lucky' } end

    env = Rack::MockRequest.env_for("/test/1?name=Lucky", "REQUEST_METHOD" => "PUT")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[true]'
  end

end

describe Sinatra::Ananke, "#trash" do

  it "should register a valid get all route for all instances of a resource in the format {resource}/?" do
    class Test; trash{|key| key.should == 1 } end

    env = Rack::MockRequest.env_for("/test/1", "REQUEST_METHOD" => "DELETE")
    status, header, body = Test.new.call(env)
    #status.should == 200
    body[0].should == '[true]'
  end

end

describe Sinatra::Ananke, "#add" do

  it "should be able to use form data as paramaters" do
    class Test; post!(:form_data){|name| name.should == 'Lucky' } end

    env = Rack::MockRequest.env_for("/test", "REQUEST_METHOD" => "POST", :input => "name=Lucky")
    status, header, body = Test.new.call(env)
    status.should == 200
    body[0].should == '[true]'
  end

end