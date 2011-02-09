require './spec/spec_helper'
require './lib/ananke'

describe 'Resource' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  #--------------------------MEDIA----------------------------------------
  it """
  Should be able to Output link to Self and Call that link
  """ do
    module Repository
      module Computer
        def self.one(id) end
        def self.add(data)
          {:user_id => 1}
        end
      end
    end
    rest :computer do
      id :user_id

    end

    post "/computer", body={:user_id => 1, :username => '1234'}
    check_status(201)
    last_response.body.should == '[{"rel":"self","uri":"/computer/1"}]'

    hash = JSON.parse(last_response.body)
    get hash[0]['uri']
    check_status(200)
  end

end