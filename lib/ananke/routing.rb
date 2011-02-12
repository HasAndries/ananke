module Ananke
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
end