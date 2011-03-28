require 'json'
module Serialize

  def self.can_serialize?(obj)
    obj.class != Array and obj.instance_variables.empty?#!obj.to_json.start_with?('"#<')
  end

  def self.unaccent(obj)
    #obj.class == String ? obj.force_encoding(Encoding::UTF_8) : obj
    #puts obj.encoding.name if obj.class == String
    obj
  end

  def self.to_h(obj)
    ret = {}

    if obj.class == Hash
      obj.each do |k, v|
        ret[k.to_sym] = (can_serialize?(v) ? unaccent(v) : Serialize.to_h(v))
      end
    elsif obj.class == Array
      ret = []
      obj.each do |i|
        #ret << (can_serialize?(i) ? i : Serialize.to_hash(i))
        ret << Serialize.to_h(i)
      end
    elsif obj.instance_variables.empty?
      ret = unaccent(obj)
    else
      obj.instance_variables.each do |e|
        value = obj.instance_variable_get e.to_sym
        ret[e[1..-1]] = (can_serialize?(value) ? unaccent(value) : Serialize.to_h(value))
      end
    end
    if ret.class == Hash and Ananke.settings[:remove_empty]
      ret.delete_if {|k,v| v.nil? || v == ''}
      ret = nil if ret.empty?
    elsif ret.class == Array and Ananke.settings[:remove_empty]
      ret.delete_if {|i| i.nil? || i == ''}
      ret = nil if ret.empty?
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