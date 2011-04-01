require 'json'

class Hash
  def to_sym
    new_hash = {}
    self.each{|k,v| new_hash[k.to_sym] = Hash === v ? v.to_sym : v}
    new_hash
  end
end

class Serialize
  class << self
    def can_serialize?(obj)
      obj.class != Array and obj.instance_variables.empty?
    end

    def to_h(obj)
      ret = {}

      if obj.class == Hash
        obj.each do |k, v|
          ret[k.to_sym] = (can_serialize?(v) ? v : Serialize.to_h(v))
        end
      elsif obj.class == Array
        ret = []
        obj.each do |i|
          ret << Serialize.to_h(i)
        end
      elsif obj.instance_variables.empty?
        ret = obj
      else
        obj.instance_variables.each do |e|
          value = obj.instance_variable_get e.to_sym
          ret[e[1..-1]] = (can_serialize?(value) ? value : Serialize.to_h(value))
        end
      end
      if ret.class == Hash
        ret.delete_if {|k,v| v.nil? || v == ''}
        ret = {} if ret.empty?
      elsif ret.class == Array
        ret.delete_if {|i| i.nil? || i == ''}
        ret = {} if ret.empty?
      end
      ret
    end

    def to_j(obj)
      Serialize.to_h(obj).to_json
    end

    def to_j_pretty(obj)
      JSON.pretty_generate(Serialize.to_h(obj), opts = {:indent => '    '})
    end
  end
end