class Hash
  def to_sym
    new_hash = {}
    self.each{|k,v| new_hash[k.to_sym] = Hash === v ? v.to_sym : v}
    new_hash
  end
end