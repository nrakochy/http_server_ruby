require 'socket'
require 'uri'
require 'thread'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params[:hostname], params[:port])
    @public_dir = File.expand_path("../../public", __FILE__)
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
    http_request = client.gets
    STDERR.puts(http_request)
    response = process_and_interpret_request(http_request)
    header = response["header"]
    puts "HEADER CLASS #{header.class}"
    response_body = response["response_body"]
    puts "BODY CLASS #{response_body.class}"
    client.print(header)
    client.print(response_body) if !response_body.empty?
    client.close
  end

  def process_and_interpret_request(request)
    parsed_data = process_request(request)
    interpret_request_method(parsed_data)
  end

  def process_request(request)
    split_req = split_http_request(request)
    method = split_req[0]
    uri = URI(split_req[1])
    post_data = URI(split_req.last)
    { "method" => method, "uri" => uri, "post_data" => post_data }
  end

  def interpret_request_method(request)
    get(request["uri"]) if request["method"] == "GET"
    #head if request["method"] == "HEAD"
    #post(request["uri"]) if request["method"] == "POST"
    #put(request["uri"]) if request["method"] == "PUT"
    #options(request["uri"]) if request["method"] == "OPTIONS"
    #delete(request["uri"]) if request["method"] == "DELETE"
  end

 def split_http_request(request)
    request.split(" ")
 end

  def get(incoming_path)
    path = incoming_path.path
    full_path = File.join(@public_dir, path)
    if legitimate_file_request?(full_path)
      response_body = read_file(full_path)
      content_type = find_content_type(full_path)
      header_info = { "status_code" => "200", "content_type" => content_type, "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_404_error
    end
  end

  def head(incoming_path)
    header_info = { "status_code" => "200", "content_type" => "text/plain", "content_length" => 0 }
    header = create_response_header(header_info)
    empty_body = ''
    [header, empty_body]
  end

  def read_file(full_path)
     file = File.open(full_path, "rb")
     data = file.read
     file.close
     data
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
      "txt" => "text/plain",
      "html" => "text/html"
    }
    content_type.default = "application/octet-stream"
    content_type[ext]
  end

  def create_response_header(response)
    "HTTP/1.1 #{response["status_code"]}\r\n" +
    "Date: #{Time.now.to_s}\r\n" +
    "Content-Type: #{response["content_type"]}\r\n" +
    "Content-Length: #{response["content_length"]}\r\n" +
    "Connection: close\r\n\r\n"
  end

  def raise_404_error
    message = "File not found"
    header_info = { "status_code" => "404 Not Found", "content_type" => "text/plain", "content_length" => message.length }
    header = create_response_header(header_info)
    { "header" => header, "response_body" => message }
  end

  def set_response_message(status_code)
    response_messages = {
      "200" => "OK",
      "201" => "Created",
      "204" => "No Content",
      "301" => "Moved Permanently",
      "302" => "Moved Temporarily",
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

