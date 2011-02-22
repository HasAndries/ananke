require './spec/spec_helper'
require './lib/ananke'

describe 'Resource Route-For' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it """
  Should be able to accept route_for Registrations
  """ do
    module Repository
      module Route_for
        def self.custom(id)
          {:route_for_id => id, :content => 'Test'}
        end
      end
    end
    route :route_for do
      id :route_for_id
      route_for :custom
    end

    get "/route_for/custom/1"
    check_status(200)
    last_response.body.should == '{"route_for_list":[{"route_for":{"route_for_id":"1","content":"Test"},"links":[{"rel":"self","uri":"/route_for/1"}]}],"links":[{"rel":"self","uri":"/route_for/custom/1"}]}'
  end

  it """
  Should be able to accept route_for Registrations
  """ do
    module Repository
      module Route_for
        def self.multi(id, name)
          {:route_for_id => id, :content => 'Test'}
        end
      end
    end
    route :route_for do
      id :route_for_id
      route_for :multi, :post
    end

    post "/route_for/multi", body={:id => 1, :name => 'some name'}
    check_status(200)
    last_response.body.should == '{"route_for_list":[{"route_for":{"route_for_id":"1","content":"Test"},"links":[{"rel":"self","uri":"/route_for/1"}]}],"links":[{"rel":"self","uri":"/route_for/multi"}]}'
  end
end