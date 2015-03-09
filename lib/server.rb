require 'socket'
require 'uri'
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
    request = client.gets
    STDERR.puts(request)

    status_code = "200"
    content_type = "text/html"
    response_body = "Hello World\n"
    header = create_response_header(status_code, content_type, response_body.length)

    client.print(header)
    client.print(response_body)
    client.close
  end

  def process_request(request)
    split_req = split_http_request(request)
    method = split_req[0]
    uri = URI(split_req[1])
    { "method" => method, "uri" => uri }
  end

  def interpret_request(request)
  end

 def split_http_request(request)
    request.split(" ")
  end

  def legitimate_file_request?(requested_file_path)
    File.exists?(requested_file_path) && !File.directory?(requested_file_path)
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
    "Date: #{Time.now.to_s}\r\n" +
    "Content-Type: #{content_type}\r\n" +
    "Content-Length: #{response_length}\r\n" +
    "Connection: close\r\n\r\n"
  end

  def set_response_message(status_code)
    response_messages = {
      "200" => "OK",
      "201" => "Created",
      "204" => "No Content",
      "301" => "Moved Permanently",
      "304" => "Not Modified",
      "400" => "Bad Request",
      "401" => "Unauthorized",
      "403" => "Forbidden",
      "404" => "Not Found",
      "500" => "Internal Server Error"
    }
    response_messages.default = "Not Found"
    response_messages[status_code]
  end
end

