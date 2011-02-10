require './spec/spec_helper'
require './lib/ananke'

describe 'Resource' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it """
  Should be able to Output link to Linkdown
  """ do
    module Repository
      module Link_to
        def self.one(id)
          {:link_id => id}
        end
      end
    end
    rest :link_to do
      id :link_id
      link_to :down
    end

    get "/linkdown/1"
    check_status(200)
    last_response.body.should == '{"link_id":"1","links":[{"rel":"self","uri":"/linkdown/1"},{"rel":"down","uri":"/down/linkdown/1"}]}'
  end
end