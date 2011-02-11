require './spec/spec_helper'
require './lib/ananke'

describe 'Link-To Resource' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it """
  Should be able to Output link to link_to
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
      link_to :to
    end

    get "/link_to/1"
    check_status(200)
    last_response.body.should == '{"link_to":{"link_id":"1"},"links":[{"rel":"self","uri":"/link_to/1"},{"rel":"to","uri":"/to/link_to/1"}]}'
  end
end