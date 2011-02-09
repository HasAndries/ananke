require './spec/spec_helper'
require './lib/ananke'

describe 'Basic Ananke REST' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end
  #----------------------------SETUP--------------------------------------
  it """
  Should be able to describe a Valid REST Resource
  """ do
    rest :user do
      id :user_id
    end
  end
  
  it """
  Should skip creating Routes for Non-Existing Repositories
  """ do
    rest :invalid do
    end
  end

  it """
  Should setup the defaults for REST
  """ do
    Ananke.default_repository.should == 'Repository'
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

  #----------------------------BASIC--------------------------------------
  it """
    GET /user
      - code:     200
      - content-type: text/plain
      - body:     [{:id=>1, :name=>'one'}, {:id => 2, :name => 'two'}]
  """ do
    get "/user"
    check_status(200)
    last_response.body.should == Repository::User.data.to_json
  end

  it """
    GET /user/1
      - code:         200
      - content-type: text/plain
      - body:         {user_id: ,username: ,email: ,country: }
  """ do
    get "/user/1"
    check_status(200)
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
    check_status(201)
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
      - body:         {user_id: ,username: ,email: ,country: }
    RETURN
      - code:         400
      - content-type: text/json
      - body:         Missing Parameter: user_id
  """ do
    put "/user", body={:user_id => 3, :username => 'four', :email => '4@four.com', :country => 'Russia'}
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
    def self.add(data)
      @data << data
      data
    end
    def self.edit(id, data)
      @data.each { |d| d = data if d[:user_id] == id}
      data
    end
    def self.delete(id)
      @data.delete_if { |i| i[:user_id] == id}
    end
  end
end