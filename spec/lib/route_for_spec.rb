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
          {:content => 'Test'}
        end
      end
    end
    route :route_for do
      id :link_id
      route_for :custom
    end

    get "/route_for/custom/1"
    check_status(200)
    last_response.body.should == '{"route_for":{"content":"Test"},"links":[{"rel":"self","uri":"/route_for"}]}'
  end

  it """
  Should be able to accept route_for Registrations
  """ do
    module Repository
      module Route_for
        def self.multi(id, name)
          {:content => 'Test'}
        end
      end
    end
    route :route_for do
      id :link_id
      route_for :multi, :post
    end

    post "/route_for/multi", body={:id => 1, :name => 'some name'}
    check_status(200)
    last_response.body.should == '{"route_for":{"content":"Test"},"links":[{"rel":"self","uri":"/route_for"}]}'
  end
end