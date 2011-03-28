require './spec/spec_helper'
require './lib/ananke/serialize'

class Simple
  attr_accessor :name, :surname
  def initialize(name, surname)
    @name = name
    @surname = surname
  end
end

class SimplePlus
  attr_accessor :name, :surname, :cars
  def initialize(name, surname, cars)
    @name = name
    @surname = surname
    @cars = cars
  end
end

class Nested
  attr_accessor :id, :simple_plus
  def initialize(id, simple_plus)
    @id = id
    @simple_plus = simple_plus
  end
end

describe Serialize, '#self.to_hash' do

  it "should serialize a simple class to hash form" do
    obj = Simple.new('test', 'test')
    Serialize.to_h(obj).should == {"name"=>"test", "surname" => "test"}
  end

  it "should serialize a simple class with a hash to hash form" do
    obj = SimplePlus.new('test', 'test', {:one => 1, :two => 2})
    Serialize.to_h(obj).should == {"name" => "test", "surname" => "test", "cars" => {:one => 1, :two => 2}}
  end

  it "should serialize a nested class to hash form" do
    obj = Nested.new(1, SimplePlus.new('test', 'test', {:one => 1, :two => 2}))
    Serialize.to_h(obj).should == {"id" => 1, "simple_plus" => {"name" => "test", "surname" => "test", "cars" => {:one => 1, :two => 2}}}
  end

end

describe Serialize, '#self.to_json' do

  it "should serialize a simple class to json" do
    obj = Simple.new('test', 'test')
    Serialize.to_j(obj).should == '{"name":"test","surname":"test"}'
  end

  it "should serialize a simple class with a hash to json" do
    obj = SimplePlus.new('test', 'test', {:one => 1, :two => 2})
    Serialize.to_j(obj).should == '{"name":"test","surname":"test","cars":{"one":1,"two":2}}'
  end

  it "should serialize a nested class to json" do
    obj = Nested.new(1, SimplePlus.new('test', 'test', {:one => 1, :two => 2}))
    Serialize.to_j(obj).should == '{"id":1,"simple_plus":{"name":"test","surname":"test","cars":{"one":1,"two":2}}}'
  end

end