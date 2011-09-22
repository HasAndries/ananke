#myapp.rb
require 'sinatra/base'
require_relative '../lib/sinatra/ananke'

#------------------------Some Data-----------------------
$DATA = {
    :carts => [
        {:id => 1, :user_id => 1, :username => 'User1', :items => [1,2]},
        {:id => 2, :user_id => 2, :username => 'User2', :items => [3]}
    ],
    :items => [
        {:id => 1,:name => 'B&H Special Mild 20', :price => 35.00, :discount => 0.1},
        {:id => 2,:name => 'Marlboro Light 10',   :price => 32.00, :country => 'usa'},
        {:id => 3,:name => 'Camel Filter 30',     :price => 40.00}
    ]
}
#------------------------Resources-----------------
resource :cart, :link_to => [:item] do
  all do
    $DATA[:carts]
  end
  one do |cart_id|
    cart = $DATA[:carts].select{|i| i[:id] == cart_id}.first
    error 404, "Cart not found" unless cart
    cart
  end
end

resource :item do
  one do |item_id|
    item = $DATA[:items].select{|i| i[:id] == item_id}.first
    error 404, "Item not found" unless item
    item
  end
  get! :cart do |cart_id|
    cart = $DATA[:carts].select{|i| i[:id] == cart_id}.first
    items = $DATA[:items].select{|i| cart[:items].include?(i[:id])} if cart
    error 404, "No Items in Cart" unless items
    items
  end
end

#------------------------Just to boot up app-------------
class Main < Sinatra::Base
  use Cart
  use Item

  run!
end

#------------------------Some Example URI's--------------
#localhost:4567/cart
#localhost:4567/cart/1
#localhost:4567/item/1
#localhost:4567/item/cart/1