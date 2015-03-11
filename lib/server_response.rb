require 'uri'
require 'cgi'

class ServerResponse
  def initialize(request)
    @method = request["method"]
    @uri = request["uri"]
    @path = @uri.path
    @incoming_data = request["incoming_data"]
    @public_dir = File.expand_path("../../public", __FILE__)
    @request_params = find_query_params
  end

  def interpret_request
    case @method
    when "GET"
      get
    when "HEAD"
      head
    when "POST"
      post
    when "PUT"
      put
    when "OPTIONS"
      options
    when "DELETE"
      delete
    else
      raise_error(404, "File not found")
    end
  end

  def get
    path = check_for_root(@path)
    full_path = set_full_path(path)
    if legitimate_file_request?(full_path)
      response_body = read_file(full_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => find_content_type(full_path), "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(404, "File not found#{@request_params}")
    end
  end

  def head
    full_path = set_full_path(@path)
    if legitimate_file_request?(full_path)
      response_body = ""
      content_type = find_content_type(full_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => content_type, "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(404, @request_params)
    end
  end

  def post
    if @path == "/form"
      full_path = set_full_path(@path)
      write_file(full_path, @incoming_data)
      response_body = read_file(full_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => "plain/text", "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(405)
    end
  end

  def put
    #NOTE: The PUT method is idempotent, whereas POST is not. This simple implementation is not using the incoming data
    #for anything, so this is written as so to eliminate redundancy, but is simply a placeholder at this point.
    #Essentially, PUT would overwrite server-side resource underlying "/form", whereas POST would pile it on.
    post
  end

  def options
    additional_information = "Allow: GET,HEAD,POST,OPTIONS,PUT\r\n"
    body = ""
    header_info = { "status_code" => set_response_message(200), "content_type" => "text/plain", "content_length" => body.length }
    header = create_response_header(header_info, additional_information)
    { "header" => header, "response_body" => body }
  end

  def delete
    if @path == "/form"
      full_path = set_full_path(@path)
      write_file(full_path, "")
      response_body = read_file(full_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => "plain/text", "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(400)
    end
  end

  def check_for_root(path)
    (path == "/") ? "/index.html" : path
  end

  def set_full_path(path)
    File.join(@public_dir, path)
  end

  def redirect_uri_path
    @uri.path = "/"
  end

  def read_file(full_path)
    file = File.open(full_path, "rb")
    data = file.read
    file.close
    data
  end

  def write_file(full_path, data)
    File.open(full_path, "wb"){ |file| file.puts data }
  end

  def legitimate_file_request?(requested_file_path)
    root = "/"
    requested_file_path == root || (File.exists?(requested_file_path) && !File.directory?(requested_file_path))
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

  def create_response_header(response, additional_information ="")
    response = ("HTTP/1.1 #{response["status_code"]}\r\n" +
                "Date: #{Time.now.to_s}\r\n" +
    "Content-Type: #{response["content_type"]}\r\n" +
    "Content-Length: #{response["content_length"]}\r\n")
    response + additional_information
  end

  def raise_error(status_code, error_message = "")
    response_code = set_response_message(status_code)
    response_body = response_code + " " + error_message
    header_info = { "status_code" => response_code, "content_type" => "text/plain", "content_length" => response_body.length }
    header = create_response_header(header_info)
    { "header" => header, "response_body" => response_body }
  end

  def set_response_message(status_code)
    response_messages = {
      200 => "200 OK",
      201 => "201 Created",
      204 => "204 No Content",
      301 => "301 Moved Permanently",
      302 => "302 Moved Temporarily",
      304 => "304 Not Modified",
      400 => "400 Bad Request",
      401 => "401 Unauthorized",
      403 => "403 Forbidden",
      404 => "404 Not Found",
      405 => "405 Method Not Allowed",
      500 => "500 Internal Server Error"
    }
    response_messages[status_code]
  end

  def find_query_params
    if @uri.query.nil?
      ""
    else
      params = CGI::parse(@uri.query)
      convert_queries_to_string(params)
    end
  end

  def convert_queries_to_string(queries)
    results = queries.map do |key, value|
      combined = value.join(" ")
      " #{key} = #{combined}\n"
    end
    puts results
    results.join('')
  end
end
