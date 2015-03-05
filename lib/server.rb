require 'socket'
require 'thread'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params[:host], params[:port])
  end

  def run
    loop {
      session = @server.accept
      Thread.start(session) do |client|
        request = session.gets
        response = "Hello world\n"
        STDERR.puts(request)
        session.print("HTTP/1.1 200 OK\r\n" +
                       "Content-Type: text/plain\r\n" +
                      "Content-Length: #{response.bytesize}\r\n" +
                       "Connection: close\r\n")
        session.print("\r\n")
        session.print(response)
        session.close
      end
    }
  end

  def serve(client)
  end

  def get
  end

  def post
  end
end

