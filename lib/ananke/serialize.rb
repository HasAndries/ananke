require 'json'
module Serialize

  def self.can_serialize?(obj)
    obj.class != Array and !obj.to_json.start_with?('"#<')
  end

  def self.to_h(obj)
    ret = {}

    if obj.class == Hash
      obj.each do |k, v|
        if !v.nil? and v != ''
          ret[k.to_sym] = (can_serialize?(v) ? v : Serialize.to_h(v))
        end
      end
    elsif obj.class == Array
      ret = []
      obj.each do |i|
        if !i.nil? and i != ''
          #ret << (can_serialize?(i) ? i : Serialize.to_hash(i))
          ret << Serialize.to_h(i)
        end
      end
    elsif obj.instance_variables.empty?
      ret = obj
    else
      obj.instance_variables.each do |e|
        value = obj.instance_variable_get e.to_sym
        if !value.nil? and value != ''
          ret[e[1..-1]] = (can_serialize?(value) ? value : Serialize.to_h(value))
        end
      end
    end
    ret
  end

  def self.to_j(obj)
    Serialize.to_h(obj).to_json
  end

  def self.to_j_pretty(obj)
    JSON.pretty_generate(Serialize.to_h(obj), opts = {:indent => '    '})
  end

end