module Ananke

  extend Colored

  public

  def get_mod(path)
    mod = nil
    rep = Module.const_get(Ananke.repository) if Module.const_defined?(Ananke.repository)
    mod = rep.const_get("#{path.capitalize}".to_sym) if !rep.nil? && rep.const_defined?("#{path.capitalize}".to_sym)
    mod
  end

  def get_json(path, obj, links)
    if obj.nil?
      out :error, "#{path} - No return object"
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

  def symbolize_keys(hash)
    new_hash = {}
    hash.each{|k,v| new_hash[k.to_sym] = Hash === v ? symbolize_keys(v) : v}
    new_hash
  end

  def collect_params(params)
    new_params = {}
    params.each do |k,v|
      json = symbolize_keys(JSON.parse(k)) if v.nil?
      if !json.nil? && !json.empty?
        new_params.merge!(json)
      else
        new_params[k.to_sym] = v
      end
    end
    new_params
  end

  def define_repository_call(mod, method_name)
    inputs = mod.method(method_name).parameters
    repository_name = mod.name.split('::').last
    call_def = "def self.call_#{repository_name}_#{method_name}(params)"
    case inputs.length
      when 0
        call_def << "#{mod}.send(:#{method_name})"
      when 1
        call_def << "#{mod}.send(:#{method_name}, params[:key])"
      else
        input_array = []
        inputs.each{|i| input_array << "params[:#{i[1]}]"}
        call_def << "#{mod}.send(:#{method_name}, #{input_array.join(',')})"
    end
    call_def << "end"
    Ananke.send(:eval, call_def)
  end

  def repository_call(mod, method_name, params)
    repository_name = mod.name.split('::').last
    Ananke.send("call_#{repository_name}_#{method_name}", params)
  end
end
