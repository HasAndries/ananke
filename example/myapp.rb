#myapp.rb
require './lib/ananke'

#------------------------DATA----------------------------
$DATA = {
    :users => {
        1 => {:name => 'User1', :cars => [1,2]},
        2 => {:name => 'User2', :cars => [3]}
    },
    :cars => {
        1 => {:make => 'Toyota'},
        2 => {:make => 'Mazda'},
        3 => {:make => 'Ford'},
    }
}

#------------------------Resources-----------------------
class User
  def cars(user_id)
    user = $DATA[:users][user_id]
    return [] if !user

    user[:cars].collect do |car_id|
      $DATA[:cars][car_id]
    end
  end
end

#------------------------Config--------------------------
user_resource = Resource.new :resource_name => :user do |r|
  r.add_call :class => User, :method => :cars
end
Ananke::Base.add_resource user_resource

Ananke.run!