#myapp.rb
require './lib/ananke'
#-----------This is only for Demo purposes------------
require 'sinatra/main'
Sinatra::Base.set :public, Proc.new { File.join(root, "../public") }
#--------------------Repositories---------------------
module Repository
  module User
    @users = [
        {:user_id => '1', :name => 'One'},
        {:user_id => '2', :name => 'Two'}]
    @user_computers = [
        {:user_id => '1', :computers => [2,3]},
        {:user_id => '2', :computers => [1]}]

    def self.all
      @users
    end
    def self.one(user_id)
      @users[@users.index{ |u| u[:user_id] == user_id}]
    end
    def self.computer_id_list(user_id)
      @user_computers[@user_computers.index{|uc| uc[:user_id] == user_id}][:computers]
    end
  end

  module Computer
    @computers = [
        {:computer_id => '1', :type => 'Intel i5 750'},
        {:computer_id => '2', :type => 'AMD Athlon'},
        {:computer_id => '3', :type => 'Intel i7 860'}]

    def self.one(id)
      @computers[@computers.index{ |c| c[:computer_id] == id}]
    end
  end

  module Car
    @cars = [
        {:car_id => 1, :make => 'Toyota'},
        {:car_id => 2, :make => 'Mazda'},
        {:car_id => 3, :make => 'Ford'},
        {:car_id => 4, :make => 'Fiat'}]
    @user_cars = [
        {:user_id => 1, :cars => [1,3]},
        {:user_id => 2, :cars => [2,4]}]
    
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

  linked :computer
  link_to :car
end

rest :computer do
  id :computer_id
end

rest :car do
  id :car_id
  
  route_for :user
end