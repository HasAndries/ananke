#myapp.rb
require 'sinatra/base'
require_relative '../lib/sinatra/ananke'

#------------------------Some Data-----------------------
$DATA = {
    :carts => [
        {:cart_id => 1, :user_id => 1, :username => 'User1', :items => [1,2]},
        {:cart_id => 2, :user_id => 2, :username => 'User2', :items => [3]}
    ],
    :items => [
        {:item_id => 1,:name => 'B&H Special Mild 20', :price => 35.00, :discount => 0.1},
        {:item_id => 2,:name => 'Marlboro Light 10',   :price => 32.00, :country => 'usa'},
        {:item_id => 3,:name => 'Camel Filter 30',     :price => 40.00}
    ]
}
#------------------------Repository Stuffs---------------
module MyRepository
  
  class ItemStuff
    def self.get_single(id)
      $DATA[:items].select{|i| i[:item_id] == id}.first
    end
    
    def self.get_by_cart(cart_id)
      $DATA[:items].select{|i| $DATA[:carts][cart_id][:items].include?(i[:item_id])}
    end
  end

  class CartStuff
    def self.get_single(id)
      $DATA[:carts].select{|i| i[:cart_id] == id}.first
    end

    def self.get_all
      $DATA[:carts]
    end
  end
end

#------------------------Definition----------------------
resource :cart, :id => :cart_id, :link_to => [:item] do

  all do
    MyRepository::CartStuff.get_all
  end

  one do |cart_id|
    cart = MyRepository::CartStuff.get_single cart_id
    error 404, "Cart not found" unless cart
    cart
  end

end

resource :item, :id => :item_id do

  one do |item_id|
    item = MyRepository::ItemStuff.get_single item_id
    error 404, "Item not found" unless item
    item
  end

  get! :cart do |cart_id|
    items = MyRepository::ItemStuff.get_by_cart cart_id
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