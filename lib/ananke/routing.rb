require 'ananke/linking'
require 'ananke/helpers'
require 'ananke/serialize'
require 'ananke/validation'

module Ananke
  public
  class << self
    attr_accessor :routes
  end

  private
  @routes = {}
  
  def add_route(name, method)
    Ananke.routes[name.to_sym] ||= []
    Ananke.routes[name.to_sym] << method.to_sym
  end
  
  def build_route(repository_module, repository_method, verb, route, &block)
    if repository_module.respond_to? repository_method
      define_repository_call(repository_module, repository_method)
      add_route(route.split('/')[1], repository_method)
      Sinatra::Base.send verb, "#{route}", do
        @params = collect_params(@params)
        instance_eval(&block)
      end
    else
      out(:warning, "#{repository_module} does not respond to '#{repository_method.to_s}'")
    end
  end

  def make_response_item(path, mod, link_list, link_to_list, obj, key)
    id = get_id(obj, key)
    out :info, "#{path} - Cannot find key(#{key}) on object #{obj}" if !id
    dic = {path.to_sym => obj}
    links = build_links(link_list, link_to_list, path, id, mod) if Ananke.settings[:links]
    dic[:links] = links if links && !links.empty?
    dic
  end

  def make_response(path, mod, link_list, link_to_list, obj, key)
    if obj.class == Array
      result_list = obj.collect{|item| make_response_item(path, mod, link_list, link_to_list, item, key) if item}.compact

      dic = result_list.empty? ? {} : {"#{path}_list".to_sym => result_list}
      link_self = build_link_self(path, '') if Ananke.settings[:links]
      dic[:links] = link_self if link_self

      Serialize.to_j(dic)
    else
      Serialize.to_j(make_response_item(path, mod, link_list, link_to_list, obj, key))
    end
  end

  def build(path)
    mod = get_repository_module(path)
    if mod.nil?
      out(:error, "Repository for #{path} not found")
      return
    end
    out :info, "No Id specified for #{path}" if @id.empty?
    key = @id[:key]
    fields = @fields
    link_list = @link_list
    link_to_list = @link_to_list
    route_for_list = @route_for_list

    #===========================GET/ID=============================
    build_route mod, :one, :get, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?

      obj, obj_status = repository_call(mod, :one, params)
      error obj_status, obj if obj_status >= 400
      not_found if obj && obj.class == Array && obj.empty?

      status obj_status
      make_response(path, mod, link_list, link_to_list, obj, key)
    end

    #===========================GET================================
    build_route mod, :all, :get, "/#{path}/?" do
      obj, obj_status = repository_call(mod, :all)
      error obj_status, obj if obj_status >= 400
      not_found if obj && obj.class == Array && obj.empty?

      status obj_status
      make_response(path, mod, link_list, link_to_list, obj, key)
    end

    #===========================POST===============================
    build_route mod, :add, :post, "/#{path}/?" do
      status, message = validate(fields, params)
      error status, message unless status.nil?

      obj, obj_status = repository_call(mod, :add, params)
      error obj_status, obj if obj_status >= 400
      not_found if obj && obj.class == Array && obj.empty?

      status 201
      make_response(path, mod, link_list, link_to_list, obj, key)
    end

    #===========================PUT================================
    build_route mod, :edit, :put, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      status, message = validate(fields, params)
      error status, message unless status.nil?

      obj, obj_status = repository_call(mod, :edit, params)
      error obj_status, obj if obj_status >= 400
      not_found if obj && obj.class == Array && obj.empty?
      
      status obj_status
      make_response(path, mod, link_list, link_to_list, obj, key)
    end

    build_route mod, :edit, :put, "/#{path}/?" do
      param_missing!(key)
    end

    #===========================DELETE=============================
    build_route mod, :delete, :delete, "/#{path}/:#{key}" do
      param_missing!(key) if params[key].nil?
      
      obj, obj_status = repository_call(mod, :delete, params)
      error obj_status, obj if obj_status >= 400
      not_found if obj && obj.class == Array && obj.empty?

      status obj_status
    end

    build_route mod, :delete, :delete, "/#{path}/?" do
      param_missing!(key)
    end

    #===========================ROUTE_FOR==========================
    route_for_list.each do |r|
      inputs = mod.method(r[:name]).parameters
      full_path = "/#{path}/#{r[:name]}"
      full_path << "/:key" if inputs.length == 1

      build_route mod, r[:name], r[:verb], full_path do
        param_missing!(:key) if inputs.length == 1 && params[:key].nil?

        obj, obj_status = repository_call(mod, r[:name], params)
        error obj_status, obj if obj_status >= 400
        not_found if obj && obj.class == Array && obj.empty?
        
        obj_list = obj.class == Array ? obj : [obj]

        status obj_status
        make_response(path, mod, link_list, link_to_list, obj_list, key).gsub("\"/#{path}/\"", "\"#{request.path}\"")
      end
    end
  end
end