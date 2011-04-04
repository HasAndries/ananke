require_relative 'base'

module Ananke
  module DSL

    def resource(name, options = {})
      resource = Resource.new :resource_name => name

      if options[:method]
        resource.add_call :class => options[:class], :method => options[:method], :type => options[:type]
      else
        options[:class].instance_methods(false).each do |method|
          type = options[:class].instance_method(method).arity > 1 ? :post : :get
          resource.add_call :class => options[:class], :method => method, :type => type
        end
      end
      
      Base.add_resource resource
    end

  end
end

include Ananke::DSL