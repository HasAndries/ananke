module Ananke
  class << self
    attr_accessor :rules
  end
  
  private
  
  @rules = [:length]

  def validate(fields, params)
    errors = []
    fields.each do |field|
      value = params[field[:key]]
      errors << "Missing Required Parameter: #{field[:key]}" if field[:type] == :required && value.nil?
      Ananke::Rules.value = value
      field[:rules].each do |r|
        res = r.class == Hash ? Ananke::Rules.send("validate_#{r.first[0]}", r.first[1]) : Ananke::Rules.send("validate_#{r}")
        errors << "#{field[:key]}: #{res}" unless res.nil?
      end
    end
    return 400, errors unless errors.empty?
  end
  def param_missing!(key)
    error 400, "Missing Parameter: #{key.to_s}"
  end

  #===========================Rules==============================
  
  module Rules
    class << self
      attr_accessor :value
    end
    def self.validate_length(min)
      value.length >= min ? nil : "Value must be at least #{min} characters long"
    end
  end
end