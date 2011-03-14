require 'json'
module Ananke

  extend Colored

  public

  def get_repository_module(path)
    repository = nil
    repository = Module.const_get(Ananke.repository) if Module.const_defined?(Ananke.repository)
    repository = repository.const_get("#{path.capitalize}".to_sym) if !repository.nil? && repository.const_defined?("#{path.capitalize}".to_sym)
    repository
  end

  def get_id(obj, key)
    if !key
      out :warning, "Cannot get id on object #{obj}, key is nil"
      return nil
    end
    obj.class == Hash && obj.has_key?(key) ? obj[key] : obj.respond_to?(key) ? obj.instance_variable_get("@#{key}") : nil
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
    repository_name = mod.name.split('::').last.downcase
    call_def = "def self.call_#{repository_name}_#{method_name}(params)\n"
    case inputs.length
      when 0
        call_def << "  #{mod}.send(:#{method_name})\n"
      when 1
        call_def << "  param = params[:key] ? params[:key] : params.values.first\n"
        call_def << "  #{mod}.send(:#{method_name}, param)\n"
      else
        input_array = []
        inputs.each{|i| input_array << "params[:#{i[1]}]"}
        call_def << "  #{mod}.send(:#{method_name}, #{input_array.join(',')})\n"
    end
    call_def << "end"
    Ananke.send(:eval, call_def)
  end

  def repository_call(mod, method_name, params = {})
    repository_name = mod.name.split('::').last.downcase
    begin
      return Ananke.send("call_#{repository_name}_#{method_name}", params), 200
    rescue StandardError => error
      raise if !error.message.start_with?(method_name.to_s)
      message = error.message.split(method_name.to_s).last.split('-').last.split(':').last.strip
      return message, 400
    end
  end
end
