require './spec/spec_helper'
require './lib/ananke'

describe 'Resource' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  before(:all) do
    rest :user do
      id :user_id
      required :username
      required 'email'
      optional :country

      media "Get All Vehicles", :get, :vehicles, :user_id
    end
  end

  it """
  Should setup the defaults for ReST
  """ do
    Ananke.default_repository.should == 'Repository'
  end

  it """
  Should setup Routes
  """ do
    Sinatra::Base.routes["GET"][-1][0].inspect.include?('user').should == true
    Sinatra::Base.routes["GET"].length.should == 2
    Sinatra::Base.routes["POST"][-1][0].inspect.include?('user').should == true
    Sinatra::Base.routes["PUT"][-1][0].inspect.include?('user').should == true
    Sinatra::Base.routes["DELETE"][-1][0].inspect.include?('user').should == true
  end

  #----------------------------BASIC--------------------------------------
  it """
    GET /user
      - code:     200
      - content-type: text/plain
      - body:     [{:id=>1, :name=>'one'}, {:id => 2, :name => 'two'}]
  """ do
    get "/user"
    last_response.status.should == 200
    last_response.body.should == Repository::User.data.to_json
  end

  it """
    GET /user/1
      - code:         200
      - content-type: text/plain
      - body:         {user_id: ,username: ,email: ,country: }
  """ do
    get "/user/1"
    last_response.status.should == 200
    last_response.body.should == Repository::User.data[0].to_json
  end

  it """
    POST /user
      - body:         {user_id: ,username: ,email: ,country: }
    RETURN
      - code:         201
      - content-type: text/json
      - body:
  """ do
    post "/user", body={:user_id => 3, :username => 'three', :email => '3@three.com', :country => 'USA'}
    last_response.status.should == 201
    last_response.body.should == ''
  end

  it """
    PUT /user/3
      - body:         {user_id: ,username: ,email: ,country: }
    RETURN
      - code:         200
      - content-type: text/json
      - body:
  """ do
    put "/user/3", body={:user_id => 3, :username => 'four', :email => '4@four.com', :country => 'Russia'}
    last_response.status.should == 200
    last_response.body.should == ''
  end

  it """
    DELETE /user/3
    RETURN
      - code:         200
      - content-type: text/json
      - body:
  """ do
    delete "/user/3"
    last_response.status.should == 200
    last_response.body.should == ''
  end
end

module Repository
  module User
    @data = [{:user_id => 1, :username => 'one', :email => '1@one.com', :country => 'South Africa'},
             {:user_id => 2, :username => 'two', :email => '2@two.com', :country => 'England'}]

    def self.data
      @data
    end

    def self.one(id)
      @data[@data.index{ |d| d[:user_id] == id.to_i}]
    end
    def self.all
      @data
    end
    def self.new(data)
      @data << data
    end
    def self.edit(id, data)
      @data.each { |d| d = data if d[:user_id] == id}
    end
    def self.delete(id)
      @data.delete_if { |i| i[:user_id] == id}
    end
  end
end