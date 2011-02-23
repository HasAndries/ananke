require './spec/spec_helper'
require './lib/ananke'

describe 'Resource Route-For' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it """
  should return a code 400 for an error raised in the Repository that has a message that starts with  the method name
  """ do
    module Repository
      module Errors
        def self.exception400(id)
          raise 'exception400 - Some Exception'
        end
      end
    end
    route :errors do
      route_for :exception400
    end

    get "/errors/exception400/1"
    check_status(400)
    last_response.body.should == 'Some Exception'
  end

  it """
  should return a code 500 for an error raised in the Repository
  """ do
    module Repository
      module Errors
        def self.exception500(id)
          raise 'Some Exception'
        end
      end
    end
    route :errors do
      route_for :exception500
    end

    get "/errors/exception500/1"
    check_status(500)
  end
end