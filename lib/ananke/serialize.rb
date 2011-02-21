require 'json'
module Serialize

  def self.to_hash(obj)
    ret = {}
    if obj.class == Hash
      obj.each do |k, v|
        ret[k.to_sym] = v.to_json.start_with?('"#<') ? Serialize.to_hash(v) : v
      end
    else
      obj.instance_variables.each do |e|
        value = obj.instance_variable_get e.to_sym
        ret[e[1..-1]] = value.to_json.start_with?('"#<') ? Serialize.to_hash(value) : value
      end
    end
    ret
  end

  def self.to_json(obj)
    Serialize.to_hash(obj).to_json
  end

end