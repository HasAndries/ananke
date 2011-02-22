require './spec/spec_helper'

describe 'Ananke - JSON Body' do
  include Rack::Test::Methods
  include Ananke

  def app
    Sinatra::Base
  end

  it "should be able to parse a JSON Body in a basic POST route" do
    post "/json", body={:name => 'one', :surname => 'sur_one'}.to_json
    check_status(201)
  end

  it "should be able to parse a JSON Body in a basic PUT route" do
    put "/json/1", body={:name => 'one', :surname => 'sur_one'}.to_json
    check_status(200)
  end

  it "should be able to parse a JSON Body in a Custom Route" do
    get "/json/custom", body={:name => 'one', :surname => 'sur_one'}.to_json
    check_status(200)
  end

  module Repository
    module Json
      @data = []
      def self.add(name, surname)
        id = @data.empty? && 1 || @data.last[:id] + 1
        obj = {:id => id, :name => name, :surname => surname}
        @data << obj
        obj
      end
      def self.edit(id, name, surname)
        obj = {:id => id, :name => name, :surname => surname}
        @data[@data.index{|i| i[:id] == id.to_i}] = obj
        obj
      end
      def self.custom(name, surname)
        @data[@data.index{|i| i[:name] == name && i[:surname] == surname}]
      end
    end
  end
  route :json do
    id :id
    required :name
    required :surname
    route_for :custom
  end
end