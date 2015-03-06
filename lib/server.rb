require 'socket'
require 'thread'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params[:host], params[:port])
    @io = params[:io]
    @io.server_started(params[:host], params[:port])
  end

  def run
    loop {
      session = @server.accept
      Thread.start(session) do |client|
        serve(client)
      end
    }
  end

  def serve(client)
    request = client.gets
    response = "Hello world\n"
    STDERR.puts(request)

    client.print("HTTP/1.1 200 \r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{response.bytesize}\r\n" +
    "Connection: close\r\n")
    client.print("\r\n")
    client.print(response)
    client.close
  end

  def find_content_type(path)
    ext = File.extname(path).split(".").last
    content_type = {
      "css" => "text/css",
      "jpg" => "image/jpeg",
      "png" => "image/png",
      "gif" => "image/gif",
      "txt" => "text/html"
    }
    content_type.default = "application/octet-stream"
    content_type[ext]
  end

  def get
  end

  def post
  end

end

