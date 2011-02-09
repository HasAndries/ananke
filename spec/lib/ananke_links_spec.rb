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
  Should be able to Output link to Self
  """ do
    module Repository
      module Basic
        def self.new(data)end
      end
    end
    rest :media_self do
      id :user_id
    end

    post "/media_self", body={:user_id => 1, :username => ''}

    post "/basic", body={:user_id => 1, :username => '1234'}
    last_response.status.should == 201
    last_response.body.should == '{:}'
  end

end