module Ananke
  class Resource
    attr_accessor :resource_name, :calls

    def initialize(options ={})
      options[:name] ||= :default
      
      @resource_name = options[:resource_name]
      
      @calls = []

      yield self if block_given?
    end

    def add_call(options ={})
      options[:type] ||= :get
      @calls << {
          :class => options[:class],
          :method => options[:method],
          :type => options[:type],
          :route => "/#{resource_name}/#{options[:method]}"
      }
    end
  end
end