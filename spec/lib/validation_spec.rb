require './spec/spec_helper'
require './lib/ananke'

describe 'Resource' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  #--------------------------VALIDATION-----------------------------------
  it """
  Should be able to use Predefined Validation:
    length
  """ do
    module Repository
      module Basic
        def self.add(data)end
      end
    end
    rest :basic do
      id :user_id
      required :username, :length => 4
    end

    post "/basic", body={:user_id => 1, :username => ''}
    check_status(400)
    last_response.body.should == 'username: Value must be at least 4 characters long'

    post "/basic", body={:user_id => 1, :username => '1234'}
    check_status(201)
  end

  it """
  Should be able to use Explicitly Defined Rule
  """ do
    module Ananke
      module Rules
        def self.validate_email
          value =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/ ? nil : "Invalid Email: #{value}"
        end
      end
    end
    Ananke::Rules.respond_to?('validate_email').should == true

    module Repository
      module Explicit
        def self.add(data)end
      end
    end
    rest :explicit do
      id :user_id
      required :email, :email
    end

    post "/explicit", body={:user_id => 1, :email => 'some'}
    check_status(400)
    last_response.body.should == 'email: Invalid Email: some'

    post "/explicit", body={:user_id => 1, :email => 'some1@some.com'}
    check_status(201)
  end

  it """
  Should be able to Add new Validations and Use them
  """ do
    rule :country, do
      value == 'South Africa' ? nil : 'Not from South Africa'
    end
    module Repository
      module Added
        def self.add(data)end
      end
    end
    rest :added do
      id :user_id
      required :country, :country
    end
    Ananke::Rules.respond_to?('validate_country').should == true

    post "/added", body={:user_id => 1, :country => 'England'}
    check_status(400)
    last_response.body.should == 'country: Not from South Africa'

    post "/added", body={:user_id => 1, :country => 'South Africa'}
    check_status(201)
  end
end