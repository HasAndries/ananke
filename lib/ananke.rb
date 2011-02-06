require 'sinatra/base'

module Ananke
  class << self
    attr_accessor :default_repository, :rules
  end

  private
  @default_repository = 'Repository'
  @rules = [:length]

  def build(path)
    #TODO - Check if Modules Exist
    mod = Module.const_get(Rest.default_repository.to_sym).const_get("#{path.capitalize}".to_sym)
    key = @id[:key]
    fields = @fields
    links = @links

    #TODO - Check if Repository Supports Resource
    Sinatra::Base.get "/#{path}/:#{key}" do
      ret = mod.one(params[key]) if !params[key].nil?
      #TODO - Hyper Links(Common place maybe?)
      ret.respond_to?(:to_json) ? ret.to_json : ret
    end

    #TODO - Check if Repository Supports Resource
    Sinatra::Base.get "/#{path}/?" do
      ret = mod.all
      #TODO - Hyper Links(Common place maybe?)
      ret.respond_to?(:to_json) ? ret.to_json : ret
    end

    #TODO - Check if Repository Supports Resource
    Sinatra::Base.post "/#{path}/?" do
      #TODO - Parameter Validation
      status, message = validate!(fields, params)
      error status, message unless status.nil?
      ret = mod.new(params)
      status 201
      #TODO - Hyper Links for Created Resource
    end

    #TODO - Check if Repository Supports Resource
    Sinatra::Base.put "/#{path}/:#{key}" do
      #TODO - Parameter Validation
      mod.edit(params[key], params) if !params[key].nil?
      status 200
      #TODO - Hyper Links
    end

    #TODO - Check if Repository Supports Resource
    Sinatra::Base.delete "/#{path}/:#{key}" do
      #TODO - Parameter Validation
      mod.delete(params[key]) if !params[key].nil?
      status 200
    end
  end

  def validate!(fields, params)
    errors = []
    fields.each do |field|
      value = params[field[:key].to_s]
      errors << "Missing Required Parameter: #{field[:key]}" if field[:type] == :required && value.nil?
      field[:rules].each do |r|
        res = r.class == Hash ? Rest::Rules.send(r.first[0], value, r.first[1]) : Rest::Rules.send(r, value)
        errors << "#{field[:key]}: #{res}" unless res.nil?
      end
    end
    return 400, errors unless errors.empty?
  end

  public

  def rest(path, &block)
    @id = {}
    @fields = []
    @links = []
    yield block
    build path
  end

  def id(key, *rules)
    @id = {:key => key, :type => :id, :rules => rules}
  end
  def required(key, *rules)
    @fields << {:key => key, :type => :required, :rules => rules}
  end
  def optional(key, *rules)
    @fields << {:key => key, :type => :optional, :rules => rules}
  end
  def media(rel, method, resource, field)
    @links << {:rel => rel, :method => method, :resource => resource, :field => field}
  end
  def rule(name, &block)
    Rest::Rules.send(:define_method, name, block)
  end

  module Rules
    def self.length(value, min)
      value.length >= min ? nil : "Value must be at least #{min} characters long"
    end
  end
end

include Rest