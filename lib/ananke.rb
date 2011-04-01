require_relative 'ananke/base'
require_relative 'ananke/main'

module Ananke
  def run!
    Ananke::Application.new.run!
  end
end

include Ananke