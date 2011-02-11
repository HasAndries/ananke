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
      :error    => true,

      :links    => true
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

  def get_json(path, obj, links)
    if obj.nil?
      out :error, "#{path} - No return object"
      ''
    elsif !obj.respond_to?(:to_json)
      out :error, "#{path} - Return object cannot be converted to JSON"
      ''
    else
      root_path = path.to_s.split('/')[0]
      dic = {root_path.to_sym => obj}
      dic[:links] = links unless links.nil?
      dic.to_json
    end
  end

  def get_id(obj, key)
    obj.respond_to?(key) ? obj.instance_variable_get(key) : obj.class == Hash && obj.has_key?(key) ? obj[key] : nil
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
    link_list = @link_list
    link_to_list = @link_to_list
    route_for_list = @route_for_list

    #===========================GET/ID=============================
    build_route mod, :one, :get, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      obj = mod.one(params[key])

      links = build_links(link_list, link_to_list, path, params[key], mod)
      json = get_json(path, obj, links)

      status 200
      json
    end

    #===========================GET================================
    build_route mod, :all, :get, "/#{path}/?" do
      obj_list = mod.all

      status 200
      #json_list = []
      result_list = []
      obj_list.each do |obj|
        id = get_id(obj, key)
        if !id.nil?
          dic = {path.to_sym => obj}
          links = build_links(link_list, link_to_list, path, id, mod) if Ananke.settings[:links]
          dic[:links] = links unless links.nil?
          result_list << dic
        else
          out :error, "#{path} - Cannot find key(#{key}) on object #{obj}"
        end
      end
      dic = {"#{path}_list".to_sym => result_list}
      link_self = build_link_self(path, '') if Ananke.settings[:links]
      dic[:links] = link_self unless link_self.nil?

      dic.to_json
    end

    #===========================POST===============================
    build_route mod, :add, :post, "/#{path}/?" do
      status, message = validate(fields, params)
      error status, message unless status.nil?
      obj = mod.add(params)

      links = build_links(link_list, link_to_list, path, params[key], mod)
      json = get_json(path, obj, links)

      status 201
      json
    end

    #===========================PUT================================
    build_route mod, :edit, :put, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      status, message = validate(fields, params)
      error status, message unless status.nil?
      obj = mod.edit(params[key], params)

      links = build_links(link_list, link_to_list, path, params[key], mod)
      json = get_json(path, obj, links)

      status 200
      json
    end

    build_route mod, :edit, :put, "/#{path}/?" do
      param_missing!(key)
    end

    #===========================DELETE=============================
    build_route mod, :delete, :delete, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      mod.delete(params[key]) if !params[key].nil?
      status 200
    end

    build_route mod, :delete, :delete, "/#{path}/?" do
      param_missing!(key)
    end

    #===========================ROUTE_FOR==========================
    route_for_list.each do |r|
      build_route mod, r[:name], :get, "/#{path}/#{r[:name]}/:key" do
        param_missing!(:key) if params[:key].nil?
        obj = mod.send(r[:name], params[:key])

        links = build_links(link_list, link_to_list, "#{path}/#{r[:name]}", params[:key], mod)
        json = get_json("#{path}/#{r[:name]}", obj, links)

        status 200
        json
      end
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

  #===========================LINKS==============================
  def build_links(link_list, link_to_list, path, id, mod)
    return if !Ananke.settings[:links]

    links = build_link_self(path, id)
    links += build_link_list(path, id, mod, link_list)
    links += build_link_to_list(path, id, link_to_list)
    
    links
  end
  #===========================SELF===============================
  def build_link_self(path, id)
    [{:rel => 'self', :uri => "/#{path}/#{id}"}]
  end
  #===========================LINKED=============================
  def build_link_list(path, id, mod, link_list)
    links = []
    link_list.each do |l|
      mod_method = "#{l[:rel]}_id_list"
      if mod.respond_to?(mod_method)
        id_list = mod.send(mod_method, id)
        id_list.each{|i| links << {:rel => "#{l[:rel]}", :uri => "/#{l[:rel]}/#{i}"}}
      else
        out :error, "#{path} - #{mod} does not respond to '#{mod_method.to_s}'"
      end
    end
    links
  end
  #===========================LINK_TO============================
  def build_link_to_list(path, id, link_to_list)
    links = []
    link_to_list.each do |l|
      links << {:rel => "#{l[:rel]}", :uri => "/#{l[:rel]}/#{path}/#{id}"}
    end
    links
  end

  public
  #===========================DSL================================
  def rest(path, &block)
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
  def route_for(rel)
    @route_for_list << {:name => rel}
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