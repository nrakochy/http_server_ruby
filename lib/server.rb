require 'socket'
require 'uri'
require 'thread'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params["hostname"], params["port"])
    @public_dir = params["public_directory"] || File.expand_path("../../public", __FILE__)
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
    http_request = retrieve_request(client)
    STDERR.puts(http_request)
    response = split_and_interpret_request(http_request)
    header = response["header"]
    response_body = response["response_body"]
    client.print(header)
    client.print(response_body) if !response_body.empty?
  ensure
    client.close
  end

  def retrieve_request(client)
    client.readpartial(800)
  end

  def split_and_interpret_request(request)
    parsed_data = split_request(request)
    interpret_request_method(parsed_data)
  end

  def split_request(request)
    split_req = request.split("\n")
    first_line = split_req[0].split(" ")
    method = first_line[0]
    uri = URI(first_line[1])
    incoming_data = split_req.last
    { "method" => method, "uri" => uri, "incoming_data" => incoming_data }
  end

  def interpret_request_method(request)
    case request["method"]
    when "GET"
      get(request["uri"])
    when "HEAD"
      head(request["uri"])
    when "POST"
      post(request)
      #when "OPTIONS"
      #  options
    else
      raise_404_error
    end

    #put(request["uri"]) if request["method"] == "PUT"
    #delete(request["uri"]) if request["method"] == "DELETE"
  end

  def get(incoming_path)
    path = incoming_path.path
    path = '/index.html' if path == "/"
    full_path = File.join(@public_dir, path)
    if legitimate_file_request?(full_path)
      response_body = read_file(full_path)
      content_type = find_content_type(full_path)
      header_info = { "status_code" => "200 OK", "content_type" => content_type, "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_404_error
    end
  end

  def head(incoming_path)
    path = incoming_path.path
    full_path = File.join(@public_dir, path)
    if legitimate_file_request?(full_path)
      response_body = ""
      content_type = find_content_type(full_path)
      header_info = { "status_code" => "200 OK", "content_type" => content_type, "content_length" => response_body.length }
      header = create_response_header(header_info)
      return { "header" => header, "response_body" => response_body }
    else
      raise_404_error
    end
  end

  def post(request)
    path = request["uri"].path
    if path == "/form"
      response_body = "Your requested data has been received: " + request["incoming_data"]
      header_info = { "status_code" => "200 OK", "content_type" => "plain/text", "content_length" => response_body.length }
      header = create_response_header(header_info)
      return { "header" => header, "response_body" => response_body }
    else
      raise_404_error
    end
  end

  def options
    message = "Allow: GET,HEAD,POST,OPTIONS,PUT,DELETE\r\n"
    body = ""
    header_info = { "status_code" => "200 OK", "content_type" => "text/plain", "content_length" => body.length }
    header = create_response_header(header_info)
    header += message
    { "header" => header, "response_body" => body }
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

