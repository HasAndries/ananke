#myapp.rb
require_relative '../lib/ananke'

#------------------------DATA----------------------------
$DATA = {
    :users => {
        1 => {:name => 'User1', :addresses => [1,2]},
        2 => {:name => 'User2', :addresses => [3]}
    },
    :addresses => {
        1 => {:street => '1 Main Road', :area => 'Durbanville', :city => 'Cape Town'},
        2 => {:unit => '561', :street => '2 Long Street', :area => 'Gardens', :city => 'Cape Town'},
        3 => {:street => '6 Dassie Street', :city => 'Bredasdorp'},
    }
}

#------------------------Resources-----------------------
class User
  def addresses(user_id)
    user = $DATA[:users][user_id]
    Ananke::Base.error!(404, 'User not found') if !user

    user[:addresses].collect do |address_id|
      $DATA[:addresses][address_id]
    end
  end
end

#------------------------Config--------------------------

use_dsl = true

if use_dsl
  resource :user, :class => User
else
  user_resource = Resource.new :resource_name => :user do |r|
    r.add_call :class => User, :method => :addresses
  end
  Ananke::Base.add_resource user_resource
end

Ananke.run!