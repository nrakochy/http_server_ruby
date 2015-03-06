require 'socket'
require 'thread'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params[:hostname], params[:port])
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
    first_line = parsed_request.first
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

  def split_http_request(request)
    request.split(" ")
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

  def create_response_header(status_code, content_type, response_length)
    "HTTP/1.1 #{status_code} #{set_response_message(status_code)}\r\n" +
    "Content-Type: #{content_type}\r\n" +
    "Content-Length: #{response_length}\r\n" +
    "Connection: close\r\n"
  end

  def set_response_message(status_code)
    response_messages = {
      200 => "OK",
      201 => "Created",
      204 => "No Content",
      301 => "Moved Permanently",
      304 => "Not Modified",
      400 => "Bad Request",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }
    response_messages.default = "Not Found"
    response_messages[status_code]
  end



  def get
  end

  def post
  end

end

