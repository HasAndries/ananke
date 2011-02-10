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

  #===========================OUTPUT=============================
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
        message = nil
    end
    puts message unless message.nil?
    message
  end

  #===========================HELPERS============================
  def get_mod(path)
    mod = nil
    rep = Module.const_get(Ananke.default_repository.to_sym) if Module.const_defined?(Ananke.default_repository.to_sym)
    mod = rep.const_get("#{path.capitalize}".to_sym) if !rep.nil? && rep.const_defined?("#{path.capitalize}".to_sym)
    mod
  end

  #===========================BUILDUP============================
  def build_route(mod, mod_method, verb, route, &block)
    if mod.respond_to? mod_method
      Sinatra::Base.send verb, "#{route}", do
        instance_eval(&block)
      end
    else
      out(:warning, "#{mod} does not respond to '#{mod_method.to_s}'")
    end
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

    build_route mod, :add, :post, "/#{path}/?" do
      status, message = validate(fields, params)
      error status, message unless status.nil?

      ret = mod.add(params)

      #TODO - Hyper Links for Created Resource
=begin
      if !links.empty?
        if ret.nil?
          out :error, "#{path} - No return object for add"
        elsif !ret.has_key?(key)
          out :error, "#{path} - Return object does not contain key(#{key})"
        else
          linkup(path, params[key], mod, links)
        end
      end
=end
      links = build_links(path, params[key], mod, links)
      #ret.nil? ? nil : ret.respond_to?(:to_json) ? ret.to_json : ret
      status 201

      j
      if ret.nil?
        out :error, "#{path} - No return object for add"
        ret = {}
      elsif !ret.respond_to?(:to_json)
        out :error, "#{path} - Return object does cannot be converted to JSON"
        ret = {}
      elsif !ret.has_key?(key)
        out :error, "#{path} - Return object does not contain key(#{key})"
      end
      json = ret.to_json
      json.insert(json.length-1, ",\"links\":#{links.to_json}")
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

  #===========================Validation=========================
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

  #===========================LINKING============================
  def build_links(path, id, mod, links)
    ret = []
    ret << {:rel => 'self', :uri => "/#{path}/#{id}"}
    ret
  end

  public

  #===========================DSL================================
  def rest(path, &block)
    @id = {}
    @fields = []
    @links = []
    yield block
    linkup :self, :get, path, @id[:key]
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
  def linkup(rel, method, resource, field)
    @links << {:rel => rel, :method => method, :resource => resource, :field => field}
  end
  def rule(name, &block)
    Ananke::Rules.send(:define_singleton_method, "validate_#{name}", block)
  end

  #===========================Rules==============================
  module Rules
    class << self
      attr_accessor :value
    end
    def self.validate_length(min)
      value.length >= min ? nil : "Value must be at least #{min} characters long"
    end
  end

  #===========================Settings===========================
  def set(name, val)
    @settings[name] = val
  end
end

include Ananke