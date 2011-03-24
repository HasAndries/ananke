require './spec/spec_helper'
require './lib/ananke'

describe 'Basic Ananke REST' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  before(:all) do
    Ananke.set :links, false
  end

  after(:all) do
    Ananke.set :links, true
  end

  #----------------------------SETUP--------------------------------------
  it """
  Should be able to describe a Valid REST Resource
  """ do
    route :user do
      id :user_id
    end
  end
  
  it """
  Should skip creating Routes for Non-Existing Repositories
  """ do
    route :invalid do
    end
  end

  it """
  Should setup the defaults for REST
  """ do
    Ananke.repository.should == :Repository
  end

  it """
  Should setup Routes
  """ do
    Sinatra::Base.routes["GET"][-1][0].inspect.include?('user').should == true
    count = 0
    Sinatra::Base.routes["GET"].each_index{|i| count += 1 if Sinatra::Base.routes["GET"][i][0].inspect.include?('user')}
    count.should == 2
    Sinatra::Base.routes["POST"][-1][0].inspect.include?('user').should == true
    Sinatra::Base.routes["PUT"][-1][0].inspect.include?('user').should == true
    Sinatra::Base.routes["DELETE"][-1][0].inspect.include?('user').should == true
  end

  it """
  Should expose routes registered
  """ do
    Ananke.routes[:user].should include :one
    Ananke.routes[:user].should include :all
    Ananke.routes[:user].should include :add
    Ananke.routes[:user].should include :edit
    Ananke.routes[:user].should include :delete
  end

  #----------------------------BASIC--------------------------------------
  it """
    GET /user
      - code:     200
      - content-type: text/plain
      - body:     [{:id=>1, :name=>'one'}, {:id => 2, :name => 'two'}]
  """ do
    get "/user"
    check_status(200)
    last_response.body.should == '{"items":[{"user":{"user_id":1,"username":"one"}},{"user":{"user_id":2,"username":"two"}}]}'
  end

  it """
    GET /user/1
      - code:         200
      - content-type: text/plain
      - body:         {user_id: ,username: }
  """ do
    get "/user/1"
    check_status(200)
    last_response.body.should == '{"user":{"user_id":1,"username":"one"}}'
  end

  it """
    POST /user
      - body:         {user_id: ,username: }
    RETURN
      - code:         201
      - content-type: text/json
      - body:
  """ do
    post "/user", body={:user_id => 3, :username => 'three'}
    check_status(201)
  end

  it """
    PUT /user/3
      - body:         {user_id: ,username: }
    RETURN
      - code:         200
      - content-type: text/json
      - body:
  """ do
    put "/user/3", body={:username => 'four'}
    check_status(200)
  end

  it """
    DELETE /user/3
    RETURN
      - code:         200
      - content-type: text/json
      - body:
  """ do
    delete "/user/3"
    check_status(200)
  end

  #----------------------------FAILS--------------------------------------
  it """
    PUT /user
      - body:         {user_id: ,username: }
    RETURN
      - code:         400
      - content-type: text/json
      - body:         Missing Parameter: user_id
  """ do
    put "/user", body={:username => 'four'}
    check_status(400)
    last_response.body.should == 'Missing Parameter: user_id'
  end

  it """
    DELETE /user
    RETURN
      - code:         400
      - content-type: text/json
      - body:         Missing Parameter: user_id
  """ do
    delete "/user"
    check_status(400)
    last_response.body.should == 'Missing Parameter: user_id'
  end
end

module Repository
  module User
    @data = [{:user_id => 1, :username => 'one'},
             {:user_id => 2, :username => 'two'}]

    def self.data
      @data
    end

    def self.one(user_id)
      @data[@data.index{ |d| d[:user_id] == user_id.to_i}]
    end
    def self.all
      @data
    end
    def self.add(user_id, username)
      obj = {:user_id => user_id.to_i, :username => username}
      @data << obj
      obj
    end
    def self.edit(user_id, username)
      obj = {:user_id => user_id.to_i, :username => username}
      @data[@data.index{|i| i[:user_id] == user_id.to_i}] = obj
      obj
    end
    def self.delete(user_id)
      @data.delete_if { |i| i[:user_id] == user_id.to_i}
    end
  end
end