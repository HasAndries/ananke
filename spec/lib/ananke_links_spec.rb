require './spec/spec_helper'
require './lib/ananke'

describe 'Resource' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it """
  Should be able to Output link to Self and Call that link
  """ do
    module Repository
      module Self
        def self.one(id) end
        def self.add(data)
          {:user_id => 1}
        end
      end
    end
    rest :self do
      id :user_id
    end

    post "/self", body={:user_id => 1, :username => '1234'}
    check_status(201)
    last_response.body.should == '{"user_id":1,"links":[{"rel":"self","uri":"/self/1"}]}'

    hash = JSON.parse(last_response.body)
    uri = hash['links'].map{|l| l['uri'] if l['rel'] == 'self'}[0]
    get uri
    check_status(200)
  end

  module Repository
    module Linkup
      def self.one(id)
        {:user_id => 1}
      end
      def self.all
        [{:user_id => 1}, {:user_id => 2}]
      end
      def self.add(data)
        {:user_id => 1}
      end
      def self.edit(id, data)
        {:user_id => 1}
      end
      def self.line_id_list(user_id)
        [1,2]
      end
    end
    module Line
      def self.one(id) end
    end
  end
  rest :linkup do
    id :user_id
    linkup :line
  end
  rest :line do
    id :line_id
  end

  it """
  Should be able to Output links to linkups and Call those links
  """ do
    post "/linkup", body={:user_id => 1, :username => '1234'}
    check_status(201)
    last_response.body.should == '{"user_id":1,"links":[{"rel":"self","uri":"/linkup/1"},{"rel":"line","uri":"/line/1"},{"rel":"line","uri":"/line/2"}]}'

    hash = JSON.parse(last_response.body)
    hash['links'].each do |l|
      get l['uri']
      check_status(200)
    end
  end

  it "Should return links on Get One" do
    #get "/linkup/1"
    #check_status(200)
    #last_response.body.should == '{"user_id":1,"links":[{"rel":"self","uri":"/linkup/1"},{"rel":"line","uri":"/line/1"},{"rel":"line","uri":"/line/2"}]}'
  end

  it """
  Should not inject links where it cannot find Repository Id lookup method
  """ do
    module Repository
      module Linkup_fail
        def self.one(id) end
        def self.add(data)
          {:user_id => 1}
        end
      end
    end
    rest :linkup_fail do
      id :user_id
      linkup :line
    end

    post "/linkup_fail", body={:user_id => 1, :username => '1234'}
    check_status(201)
    last_response.body.should == '{"user_id":1,"links":[{"rel":"self","uri":"/linkup_fail/1"}]}'
  end
end