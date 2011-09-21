require 'json'
require 'sinatra/base'

module Sinatra
  module Ananke

    class Serialize
      class << self
        def can_serialize?(obj) obj.class != Array and obj.instance_variables.empty? end

        def to_h(obj, options = {})
          ret = {}
          if obj.class == Hash
            obj.each do |k, v|
              ret[k.to_sym] = (can_serialize?(v) ? v : Serialize.to_h(v, options))
            end
          elsif obj.class == Array
            ret = obj.collect {|i| Serialize.to_h(i, options)}
          elsif obj.instance_variables.empty?
            ret = obj
          else
            obj.instance_variables.each do |e|
              value = obj.instance_variable_get e.to_sym
              ret[e[1..-1]] = (can_serialize?(value) ? value : Serialize.to_h(value, options))
            end
          end
          if ret.respond_to? :delete_if
            ret.delete_if {|k,v| v.nil? || v == ''} if ret.class == Hash && options[:remove_empty]
            ret.delete_if {|i| i.nil? || i == ''} if ret.class == Array && options[:remove_empty]
            ret = {} if ret.empty?
          end
          ret
        end

        def to_a(obj, options = {}) ret = Serialize.to_h(obj, options); ret.class == Array && ret || [ret] end
        def to_j(obj, options = {}) Serialize.to_h(obj, options).to_json end
        def to_j_pretty(obj, options = {}) JSON.pretty_generate(Serialize.to_h(obj, options), opts = {:indent => '    '}) end
      end
    end
    
    module Helpers
      def collect_input_params(params, &block)
        block_params = block.parameters.collect {|p| p[1]}
        block_params.collect do |param|
          error(400, "Missing parameter - #{param}") unless params.has_key? param.to_s
          value = params[param]
          case
            when value.to_i.to_s == value; value.to_i
            when value.to_f.to_s == value; value.to_f
            else value
          end
        end
      end

      def inject_app(resource_classes)
        resource_classes.each do |klass|
          klass.send :define_method, :app, do klass.class_variable_get :@@app end unless klass.method_defined? :app
          klass.send :class_variable_set, :@@app, self
        end
      end
    end

    public

    class << self
      attr_accessor :resource_module
    end

    def self.registered(app)
      app.helpers Ananke::Helpers
    end

    attr_reader :resource_name, :resource_id, :resource_link_to, :resource_classes, :resource_mime, :resource_remove_empty
    def resource_link_self?() @resource_link_self end

    def make_resource(name, options = {})
      reset!
      options[:id]        ||= :id
      options[:link_self]   = options.has_key?(:link_self) ? options[:link_self] : true
      options[:link_to]   ||= []
      options[:classes]   ||= []

      @resource_name      = name
      @resource_id        = options[:id]
      @resource_link_self = options[:link_self]
      @resource_link_to   = options[:link_to]
      @resource_classes   ||= []
      @resource_mime      = options[:mime]
      @resource_remove_empty      = options.has_key?(:remove_empty) ? options[:remove_empty] : false

      options[:classes].each {|c| add_class c}
    end

    def add_class(klass)
      @resource_classes << klass
      klass.public_instance_methods(false).each do |method_name|
        block = klass.new.method(method_name).to_proc
        if [:one,:all,:add,:edit,:trash].include? method_name
          method(method_name).call({}, &block)
        else
          get!(method_name, {}, &block) if block.arity <= 1
          post!(method_name, {}, &block) if block.arity > 1
        end
      end
    end

    def get!(path, options={}, &block) rest :get, path, options, &block end
    def post!(path, options={}, &block) rest :post, path, options, &block end
    def put!(path, options={}, &block) rest :put, path, options, &block end
    def delete!(path, options={}, &block) rest :delete, path, options, &block end

    def one(options={}, &block) rest :get, ":#{resource_id}", options, &block end
    def all(options={}, &block) rest :get, '?', options, &block end
    def add(options={}, &block) rest :post, '?', options, &block end
    def edit(options={}, &block) rest :put, ":#{resource_id}", options, &block end
    def trash(options={}, &block) rest :delete, ":#{resource_id}", options, &block end

    private

    def rest(type, path, options={}, &block)
      res = {
          :name => resource_name,
          :id => resource_id,
          :link_self => resource_link_self?,
          :link_to => resource_link_to,
          :classes => resource_classes,
          :remove_empty => resource_remove_empty
      }
      id_param = options.delete :id
      block_params = block.parameters.collect {|p| p[1]}
      path = "#{path}/:#{block_params[0]}" if (block_params.length == 1 && path != ":#{block_params[0]}") || id_param

      method(type).call "/#{resource_name}/#{path}", options, do
        inject_app(res[:classes])
        input_params = collect_input_params(params, &block)

        result = instance_exec(*input_params, &block)
        result = Serialize.to_h(result, :remove_empty => res[:remove_empty])
        result = [result] unless result.respond_to? :each

        #inject links
        (result.class == Array && result || [result]).each do |item|
          next unless item.respond_to?(:has_key?) && item.has_key?(res[:id])
          links = []
          links << {:rel => :self, :href => "/#{res[:name]}/#{item[res[:id]]}"} if res[:link_self]
          links.concat(res[:link_to].collect { |link| {:rel => link, :href => "/#{link}/#{res[:name]}/#{item[res[:id]]}"}})
          item[:links] = links unless links.empty?
        end

        content_type :json
        Serialize.to_j result
      end
    end

  end

  register Ananke
  helpers Ananke::Helpers
end

module DSL
  def resource(name, options={}, &block)
    resource_module = Sinatra::Ananke.resource_module && Sinatra::Ananke.resource_module.to_s.capitalize.to_sym || nil
    Object.const_set(resource_module, Module::new) if resource_module && !Object.const_get(resource_module)
    Object.const_set(options[:module].to_s.capitalize, Module::new) if options[:module] && [String, Symbol].include?(options[:module].class)
    container = options[:module] ? Object.const_get(options[:module].to_s.capitalize) : self.respond_to?(:name) ? self : resource_module ? Object.const_get(resource_module) : Object
    full_name = name.capitalize.to_sym
    container::const_set(full_name, Class::new(Sinatra::Base) do
      register Sinatra::Ananke
    end) unless container::const_defined?(full_name)

    klass = container::const_get(full_name)
    klass.make_resource name, options
    klass.instance_eval(&block) if block_given?
  end
end

include DSL
#Defaults
Sinatra::Ananke.resource_module=nil
