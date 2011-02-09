#myapp.rb
require './lib/ananke'
#-----------This is only for Demo purposes------------
require 'sinatra/main'
Sinatra::Base.set :public, Proc.new { File.join(root, "../public") }
#--------------------Repositories---------------------
module Repository
  module User
    @data = [{:id => '1', :name => 'One'}, {:id => '2', :name => 'Two'}]
    def self.all
      @data.to_s
    end
    def self.one(id)
      index = @data.index{ |d| d[:id] == id}
      (index.nil? && '') || @data[index].to_s
    end
  end
end
#-------------------REST Resources--------------------
rest :user do
  id :id
end