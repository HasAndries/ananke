require 'colored'
require 'rack'
require_relative 'resource'
require_relative 'errors'
require_relative 'helpers'
require_relative 'serialize'

module Ananke
  extend Colored
  
  class Base
    include Rack::Utils
    attr_accessor :app
    attr_accessor :env, :request, :params, :resources

    def initialize(app=nil)
      @app = app
      yield self if block_given?
    end

    def call(env)
      @env      = env
      @request  = Rack::Request.new(env)
      @response = Rack::Response.new

      begin
        result = Base.route! @request

        if result.respond_to?(:has_key?)
          @response.status = result[:body] if result.has_key? :body
          @response['Content-Type'] = result[:content_type] if result.has_key? :content_type
          @response.body = result[:body] if result.has_key? :body
        else
          @response['Content-Type'] = 'json'
          @response.body = result
        end

        status, header, @response = @response.finish
        body = [Serialize.to_j(@response.body)]

        if @env['REQUEST_METHOD'] == 'HEAD'
          body = []
          header.delete('Content-Length') if header['Content-Length'] == '0'
        end

      rescue MissingParameterError => e
        status, header, body = 400, {'Content-Type' => 'html'}, [html(e.message)]
      rescue MissingRouteError => e
        status, header, body = 404, {'Content-Type' => 'html'}, [html(e.message)]
      rescue StandardError => e
        status, header, body = 500, {'Content-Type' => 'html'}, [html(e.message, '', e.backtrace)]
      end

      out = "#{status} - #{request.request_method} #{request.url}"
      case
      when (200..299).include?(status)
        puts out.green.bold
      when (300..399).include?(status)
        puts out.yellow.bold
      when (400..499).include?(status)
        puts out.magenta.bold
      when (500..599).include?(status)
        puts "#{out}, #{e.message}".red.bold
      else
        puts "#{out}".red.bold
      end

      [status, header, body]
    end

    def html(*parts)
      ret =  "<html>\n"
      ret << "  <head></head>\n"
      ret << "  <body>\n"
      ret << parts.join("<br>\n")
      ret << "  </body>\n"
      ret << "</html>"
    end

    class << self
      public
      attr_accessor :resources, :routes, :run

      def add_resource(resource)
        @resources ||= {}
        @resources[resource.resource_name] = resource
        resource.calls.each do |call|
          routes[call[:route]] = call
        end
      end

      def route!(request)
        path = Rack::Utils.unescape(request.path_info)
        path = path.empty? ? "/" : path

        call = routes[path]
        raise MissingRouteError, "#{request.request_method} #{request.url} not found" unless call && call[:type] == request.request_method.downcase.to_sym

        params = request.params.to_sym
        obj = call[:class].new
        method_params = obj.method(call[:method]).parameters.collect {|p| p[1]}
        input_params = method_params.collect do |method_param|
          value = params[method_param]
          case
            when value.to_i.to_s == value
              value.to_i
            when value.to_f.to_s == value
              value.to_f
            else
              value
          end
        end

        #Need to do Param validation here
        input_params.each do |param|
          raise MissingParameterError, "#{request.request_method} #{request.url} requires parameters: #{method_params.join(', ')}" unless param
        end
        
        obj.send(call[:method], *input_params)
      end

      def reset!
        @resources = {}
        @routes = {}
      end

      private
      
    end

  end
end

Ananke::Base.reset!
