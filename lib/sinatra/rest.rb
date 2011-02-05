require 'sinatra/base'

module Rest
  class << self
    attr_accessor :default_repository
  end
  
  private
  @default_repository = 'Repository'

  def build(path)
    #TODO - Check if Modules Exist
    mod = Module.const_get(Rest.default_repository.to_sym).const_get("#{path.capitalize}".to_sym)
    key = @id[:key]

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
      mod.trash(params[key]) if !params[key].nil?
      status 200
    end
  end

  public

  def rest(path, &block)
    @id = {}
    @fields = []
    @links = []
    yield block
    build path
  end

  def id(key, *validations)
    @id = {:key => key, :type => :id, :rules => validations}
  end
  def required(key, *validations)
    @fields << {:key => key, :type => :required, :rules => validations}
  end
  def optional(key, *validations)
    @fields << {:key => key, :type => :optional, :rules => validations}
  end
  def media(rel, method, resource, field)
    @links << {:rel => rel, :method => method, :resource => resource, :field => field}
  end
end

include Rest