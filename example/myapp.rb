#myapp.rb
require './lib/ananke'
#-----------This is only for Demo purposes------------
require 'sinatra/main'
Sinatra::Base.set :public, Proc.new { File.join(root, "../public") }
#-----------------------Data--------------------------
@users = [
    {:user_id => '1', :name => 'One'},
    {:user_id => '2', :name => 'Two'}]
@cars = [
    {:car_id => 1, :make => 'Toyota'},
    {:car_id => 2, :make => 'Mazda'},
    {:car_id => 3, :make => 'Ford'},
    {:car_id => 4, :make => 'Fiat'}]
@user_cars = [
    {:user_id => 1, :cars => [1,3]},
    {:user_id => 2, :cars => [2,4]}]
#--------------------Repositories---------------------
module Repository
  module User
    def self.all
      @users
    end
    def self.one(user_id)
      @users[@users.index{ |u| u[:user_id] == user_id}]
    end
    def self.car_id_list(user_id)
      @user_cars[@user_cars.index{|uc| uc[:user_id] == user_id}][:cars]
    end
  end

  module Car
    def self.user(id)
      car_id_list = []
      @user_cars.each{|i| car_id_list += i[:cars] if i[:user_id] == id.to_i }
      car_id_list.map do |car_id|
        @cars[@cars.index{ |c| c[:car_id] == car_id}]
      end
    end
  end
end
#-------------------REST Resources--------------------
rest :user do
  id :user_id

  linked :car
  link_to :car
end

rest :car do
  id :car_id
  
  route_for :user
end