libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'colored'
require 'sinatra/base'

require 'ananke/helpers'
require 'ananke/linking'
require 'ananke/routing'
require 'ananke/settings'
require 'ananke/serialize'
require 'ananke/validation'

module Ananke
  private

  public
  #===========================DSL================================
  def route(path, &block)
    @id = {}
    @fields = []
    @link_list = []
    @link_to_list = []
    @route_for_list = []
    yield block
    build path
  end

  def id(key, *rules)
    @id = {:key => key, :type => :id, :rules => rules}
  end
  def required(key, *rules)
    @fields << {:key => key, :type => :required, :rules => rules}
  end
  def optional(key, *rules)
    @fields << {:key => key, :type => :optional, :rules => rules}
  end
  def linked(rel)
    @link_list << {:rel => rel}
  end
  def link_to(rel)
    @link_to_list << {:rel => rel}
  end
  def route_for(rel, verb = :get)
    @route_for_list << {:name => rel, :verb => verb}
  end
  def rule(name, &block)
    Ananke::Rules.send(:define_singleton_method, "validate_#{name}", block)
  end
end

include Ananke