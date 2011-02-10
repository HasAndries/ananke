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
end
#-------------------REST Resources--------------------
rest :user do
  id :user_id

  linked :computer
end
rest :computer do
  id :computer_id
end