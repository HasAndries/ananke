require 'colored'
require 'json'
require 'sinatra/base'

module Ananke
  class << self
    attr_accessor :default_repository, :rules, :settings
  end
  
  private
  extend Colored
  
  @default_repository = 'Repository'
  @rules = [:length]
  @settings = {
      :output   => true,
      :info     => true,
      :warning  => true,
      :error    => true
  }

  #-------------Output Methods--------------
  def out(type, message)
    return if !Ananke.settings[:output]
    message = case
      when type == :info && Ananke.settings[:info]
        message.blue
      when type == :warning && Ananke.settings[:warning]
        message.yellow
      when type == :error && Ananke.settings[:error]
        message.red
      else
        message
    end
    puts message
    message
  end

  #-------------Helpers---------------------
  def get_mod(path)
    mod = nil
    rep = Module.const_get(Ananke.default_repository.to_sym) if Module.const_defined?(Ananke.default_repository.to_sym)
    mod = rep.const_get("#{path.capitalize}".to_sym) if !rep.nil? && rep.const_defined?("#{path.capitalize}".to_sym)
    mod
  end

  #-------------Buildup---------------------
  def build_route(mod, mod_method, verb, route, &block)
    if mod.respond_to? mod_method
      Sinatra::Base.send verb, "#{route}", do
        instance_eval(&block)
      end
    else
      out(:warning, "#{mod} does not respond to '#{mod_method.to_s}'")
    end
  end

  def build_links(path, id)
    links = []
    links << {:rel => :self, :uri => "/#{path}/:#{id}"}
    links
  end
  
  def build(path)
    mod = get_mod(path)
    if mod.nil?
      out(:error, "Repository for #{path} not found")
      return
    end
    key = @id[:key]
    fields = @fields
    links = @links

    build_route mod, :one, :get, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      ret = mod.one(params[key])

      status 200
      #TODO - Hyper Links(Common place maybe?)
      ret.nil? ? nil : ret.respond_to?(:to_json) ? ret.to_json : ret
    end

    build_route mod, :all, :get, "/#{path}/?" do
      ret = mod.all

      status 200
      #TODO - Hyper Links(Common place maybe?)
      ret.nil? ? nil : ret.respond_to?(:to_json) ? ret.to_json : ret
    end

    build_route mod, :new, :post, "/#{path}/?" do
      status, message = validate(fields, params)
      error status, message unless status.nil?

      ret = mod.new(params)

      status 201
      #TODO - Hyper Links for Created Resource
      build_links(path, ret[key])
      #ret.nil? ? nil : ret.respond_to?(:to_json) ? ret.to_json : ret
    end

    build_route mod, :edit, :put, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      status, message = validate(fields, params)
      error status, message unless status.nil?
      
      ret = mod.edit(params[key], params)

      status 200
      #TODO - Hyper Links(Common place maybe?)
      #ret.nil? ? nil : ret.respond_to?(:to_json) ? ret.to_json : ret
    end

    build_route mod, :edit, :put, "/#{path}/?" do
      param_missing!(key)
    end

    build_route mod, :delete, :delete, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?

      mod.delete(params[key]) if !params[key].nil?
      
      status 200
    end

    build_route mod, :delete, :delete, "/#{path}/?" do
      param_missing!(key)
    end
  end

  #-------------Validation------------------
  def validate(fields, params)
    errors = []
    fields.each do |field|
      value = params[field[:key].to_s]
      errors << "Missing Required Parameter: #{field[:key]}" if field[:type] == :required && value.nil?
      Ananke::Rules.value = value
      field[:rules].each do |r|
        res = r.class == Hash ? Ananke::Rules.send("validate_#{r.first[0]}", r.first[1]) : Ananke::Rules.send("validate_#{r}")
        errors << "#{field[:key]}: #{res}" unless res.nil?
      end
    end
    return 400, errors unless errors.empty?
  end
  def param_missing!(key)
    error 400, "Missing Parameter: #{key.to_s}"
  end

  public

  #-------------DSL-------------------------
  def rest(path, &block)
    @id = {}
    @fields = []
    @links = []
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
  def media(rel, method, resource, field)
    @links << {:rel => rel, :method => method, :resource => resource, :field => field}
  end
  def rule(name, &block)
    Ananke::Rules.send(:define_singleton_method, "validate_#{name}", block)
  end

  #-------------Rules-----------------------
  module Rules
    class << self
      attr_accessor :value
    end
    def self.validate_length(min)
      value.length >= min ? nil : "Value must be at least #{min} characters long"
    end
  end

  #-------------Settings--------------------
  def set(name, val)
    @settings[name] = val
  end
end

include Ananke