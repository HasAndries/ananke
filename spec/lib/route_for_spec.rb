require './spec/spec_helper'
require './lib/ananke'

describe 'Resource Route-For' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it """
  should be able to accept route_for Registrations
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
    last_response.body.should == '{"items":[{"route_for":{"route_for_id":"1","content":"Test"},"links":[{"rel":"self","uri":"/route_for/1"}]}],"links":[{"rel":"self","uri":"/route_for/custom/1"}]}'
  end

  it """
  should be able to accept route_for Registrations with POST and multiple input parameters
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
    last_response.body.should == '{"items":[{"route_for":{"route_for_id":"1","content":"Test"},"links":[{"rel":"self","uri":"/route_for/1"}]}],"links":[{"rel":"self","uri":"/route_for/multi"}]}'
  end

  it """
  should be able to register multiple route_for's in one declaration
  """ do
    module Repository
      module Route_for
        def self.get_1(id)
        end
        def self.get_2(id)
        end
      end
    end
    route :route_for do
      id :route_for_id
      route_for :get_1
      route_for :get_2
    end

    get "/route_for/get_1/1"
    check_status(200)
    get "/route_for/get_2/2"
    check_status(200)
  end

  it """
  should be able to register multiple route_for's with POST in one declaration
  """ do
    module Repository
      module Route_for
        def self.post_1(id)
        end
        def self.post_2(id)
        end
      end
    end
    route :route_for do
      id :route_for_id
      route_for :post_1, :post
      route_for :post_2, :post
    end

    post "/route_for/post_1/1"
    check_status(200)
    post "/route_for/post_2/2"
    check_status(200)
  end
end