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
end
