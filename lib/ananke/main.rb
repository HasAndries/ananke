require_relative 'base'

module Ananke
  class Application < Base
    public

    attr_accessor :run, :server, :host, :port

    class << self
      @run = Proc.new { $0 == caller_files.first || $0 }
      
      def run?
        @run
      end
    end

    def quit!(server, handler_name)
      server.respond_to?(:stop!) ? server.stop! : server.stop
      puts "Ananke - #{host}:#{port} Stopped".blue.bold unless handler_name =~/cgi/i
    end

    def run!(options={})
      @server = %w[thin mongrel webrick]
      @host = 'localhost'
      @port = 4040

      handler      = detect_rack_handler
      handler_name = handler.name.gsub(/.*::/, '')
      puts "Ananke - #{host}:#{port} Started".green.bold

      handler.run self, :Host => host, :Port => port do |server|
        [:INT, :TERM].each { |sig| trap(sig) { quit!(server, handler_name) } }
      end
    rescue Errno::EADDRINUSE => e
      puts "Ananke - #{host}:#{port} Port already in use".red.bold
    end

    private

    def detect_rack_handler
      servers = Array(server)
      servers.each do |server_name|
        begin
          return Rack::Handler.get(server_name.downcase)
        rescue LoadError
        rescue NameError
        end
      end
      fail "Server handler (#{servers.join(',')}) not found."
    end

  end

  at_exit { Application.run! if $!.nil? && Application.run? }
end
