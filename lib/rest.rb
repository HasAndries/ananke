require 'sinatra/base'

module Rest
  class << self
    attr_accessor :default_repository
  end
  
  private
  @default_repository = 'Repository'

  def build(path)
    mod = Module.const_get(Rest.default_repository.to_sym).const_get("#{path.capitalize}".to_sym)
    key = @id[:key]
    Sinatra::Base.get "/#{path}/:user_id" do
      ret = mod.one(params[key]) if !params[key].nil?
      ret.respond_to?(:to_json) ? ret.to_json : ret
    end
    Sinatra::Base.get "/#{path}/?" do
      ret = mod.all
      ret.respond_to?(:to_json) ? ret.to_json : ret
    end
    Sinatra::Base.post "/#{path}/?" do
      ret = mod.new(params)
      status 200
    end
    Sinatra::Base.put "/#{path}/:id" do
      mod.edit(params[key], params) if !params[key].nil?
      status 200
    end
    Sinatra::Base.delete "/#{path}/:id" do
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