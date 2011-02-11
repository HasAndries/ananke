require './spec/spec_helper'
require './lib/ananke'

describe 'Ananke Console Output' do
  include Ananke

  it """
  Should be able to output in different Colors
  """ do
    output = Ananke.settings[:output]
    Ananke.set :output, true

    Ananke.send(:out, :info, 'test').should == 'test'.blue
    Ananke.send(:out, :error, 'test').should == 'test'.red
    Ananke.send(:out, :warning, 'test').should == 'test'.yellow
    Ananke.send(:out, :some_other, 'test').should == nil

    Ananke.set :output, output
  end
end