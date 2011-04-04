require 'colored'
require 'rack'

require_relative 'helpers'
require_relative 'resource'

module Ananke
  extend Colored

  class AnankeError < StandardError
  end

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

        status = 200
        header = {'Content-Type' => 'json'}
        body = []

        if result.respond_to?(:has_key?) and result.has_key? :body and result.has_key? :content_type and result.has_key? :body
          status = result[:body]
          header['Content-Type'] = result[:content_type]
          body = [result[:body]]
        elsif @env['REQUEST_METHOD'] != 'HEAD'
          body = [result]
        end

        body = [Serialize.to_j(body[0])] if body.length > 0
        header['Content-Length'] = body[0].length.to_s unless body.empty? or body[0].length == 0
        
      rescue AnankeError => e
        status, header, body = format_error e.message[0], e.message[1]
      rescue StandardError => e
        log "#{e.message}\n#{e.backtrace}", :red
        status, header, body = format_error 500, e.message, e.backtrace
      end

      log_request status, @request

      [status, header, body]
    end

    private

    def format_error(status, message, backtrace = nil)
      body  = "<html><head></head><body>"
      body << "<h1>#{status}</h1><h2>#{message}</h2>"
      body << "<h2>Trace</h2>\n<br>#{backtrace.join("<br>\n")}</body></html>" if backtrace
      body << "</body></html>"
      [status, {'Content-Type' => 'html', 'Content-Length' => "#{body.length}"}, [body]]
    end

    def log_request(status, request)
      out = "#{status} - #{request.request_method} #{request.url}"
      case
      when (200..299).include?(status)
        log out, :green, true
      when (300..399).include?(status)
        log out, :yellow, true
      when (400..499).include?(status)
        log out, :magenta, true
      when (500..599).include?(status)
        log out, :red, true
      else
        log out, :red, true
      end
    end

    def log(obj, color, bold = false)
      message = obj.class == String ? obj : obj.to_s
      message = message.send color
      message = message.bold if bold
      puts message
      message
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
        error!(404, "Resource Not found") unless call && call[:type] == request.request_method.downcase.to_sym

        instance = call[:class].new
        input_params = collect_input_params instance.method(call[:method]), request.params.to_sym

        #Need to do Param validation here
        input_params.each do |param|
          
        end
        
        instance.send(call[:method], *input_params)
      end

      def collect_input_params(method, params)
        method_params = method.parameters.collect {|p| p[1]}

        method_params.collect do |method_param|
          error!(400, "Missing parameter - #{method_param}") unless params.has_key? method_param
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
      end

      def error!(status = 500, message = 'Internal Error')
        raise AnankeError, [status, message]
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
