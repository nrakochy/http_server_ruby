require 'socket'
require 'thread'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params[:hostname], params[:port])
    puts("Server started and listening on #{params[:host]}#{params[:port]}")
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
    request = client.gets.to_s
    parsed_request = split_request_by_line(request)
    client.print(parsed_request)
    first_line = parsed_request.first
    #request_type = first_line.first
    requested_file_path = first_line[1]

    if legitmate_file_request?(requested_file_path)
      status_code = 200
      response_body = "Hello World\n"
    end

    STDERR.puts(request)

      client.print("HTTP/1.1 #{status_code} \r\n" +
                   "Content-Type: text/plain\r\n" +
                   "Content-Length: #{response_body.bytesize}\r\n" +
    "Connection: close\r\n")
      client.print("\r\n")
      client.print(response_body)
      client.close
  end

  def legitimate_file_request?(requested_file_path)
    File.exists?(requested_file_path) && !File.directory?(requested_file_path)
  end

  def split_request_by_line(request)
    full_request = request.split("\n")
    full_request.map{ |line| split(" ") }
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

  def raise_http_response(type)
  end

  def set_status_code
  end

  def get
  end

  def post
  end

end

