require 'json'
module Serialize

  def self.can_serialize?(obj)
    obj.class != Array and !obj.to_json.start_with?('"#<')
  end

  def self.to_hash(obj)
    ret = {}

    if obj.class == Hash
      obj.each do |k, v|
        ret[k.to_sym] = (can_serialize?(v) ? v : Serialize.to_hash(v))
      end
    elsif obj.class == Array
      ret = []
      obj.each do |i|
        ret << (can_serialize?(i) ? i : Serialize.to_hash(i))
      end
    else
      obj.instance_variables.each do |e|
        value = obj.instance_variable_get e.to_sym
        ret[e[1..-1]] = (can_serialize?(value) ? value : Serialize.to_hash(value))
      end
    end
    ret
  end

  def self.to_json(obj)
    Serialize.to_hash(obj).to_json
  end

  def self.to_json_pretty(obj)
    JSON.pretty_generate(Serialize.to_hash(obj), opts = {:indent => '    '})
  end

end