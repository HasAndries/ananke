require './spec/spec_helper'
require './lib/ananke'

describe 'Ananke Console Output' do
  include Ananke

  before(:all) do
    Ananke.set :output, true
  end
  after(:all) do
    Ananke.set :output, false
  end

  it """
  Should be able to output in different Colors
  """ do
    Ananke.send(:out, :info, 'test').should == 'test'.blue
    Ananke.send(:out, :error, 'test').should == 'test'.red
    Ananke.send(:out, :warning, 'test').should == 'test'.yellow
    Ananke.send(:out, :some_other, 'test').should == 'test'
  end
end