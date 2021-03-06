require 'uri'
require 'response/file_accessor'

class ResponseHandler
  def initialize(request)
    @uri = request["uri"]
    @incoming_data = request["incoming_data"]
    @etag = request["etag"]
    @request_params = request["query_params"]
    @relative_path = @uri.path
    @public_dir = File.expand_path("../../../public", __FILE__)
    @abs_path = File.join(@public_dir, @relative_path)
    @file_accessor = FileAccessor.new
  end

  def get
    if @file_accessor.legitimate_request?(@abs_path)
      path_to_file = serve_file_path(@relative_path)
      response_body = @file_accessor.read_file(path_to_file)
      header = build_get_response_header(path_to_file, response_body)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(404, "File not found#{@request_params}")
    end
  end

  def head
    if @file_accessor.legitimate_request?(@abs_path)
      response_body = ""
      header_info = { "status_code" => set_response_message(200), "content_type" => "plain/text", "content_length" => 0 }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(404)
    end
  end

  def post
    if @relative_path == "/form"
      @file_accessor.append_file(@abs_path, @incoming_data)
      response_body = @file_accessor.read_file(@abs_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => "plain/text", "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(405)
    end
  end

  def put
    if @relative_path == "/form"
      @file_accessor.write_file(@abs_path, @incoming_data)
      response_body = @file_accessor.read_file(@abs_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => "plain/text", "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(405)
    end
  end

  def options
    additional_information = "Allow: GET,HEAD,POST,OPTIONS,PUT\r\n"
    body = ""
    header_info = { "status_code" => set_response_message(200), "content_type" => "text/plain", "content_length" => body.length }
    header = create_response_header(header_info, additional_information)
    { "header" => header, "response_body" => body }
  end

  def delete
    if @relative_path == "/form"
      @file_accessor.write_file(@abs_path, "")
      response_body = @file_accessor.read_file(@abs_path)
      header_info = { "status_code" => set_response_message(200), "content_type" => "plain/text", "content_length" => response_body.length }
      header = create_response_header(header_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(400)
    end
  end

  def patch
    if @relative_path == "/patch-content.txt"
      updated_record = {"etag": @etag, "data": @incoming_data }
      status_code = route_based_on_etag(updated_record)
      #NOTE: file is not writing
      response_body = "#{@incoming_data}"
      header_info = { "status_code" => set_response_message(status_code), "content_type" => "plain/text", "content_length" => response_body.length }
      patch_info = "ETAG: #{@etag}\r\n"
      header = create_response_header(header_info, patch_info)
      { "header" => header, "response_body" => response_body }
    else
      raise_error(404)
    end
  end

  def serve_file_path(path, redirect_path = "/index.html")
    if path == "/" || path == "/redirect"
      @public_dir + redirect_path
    else
      @abs_path
    end
  end

  def route_based_on_etag(updated_record)
    if @file_accessor.matching_etag?(@abs_path, updated_record)
      return 304
    else
      @file_accessor.patch_record(@abs_path, updated_record)
      return 204
    end
  end

  def build_get_response_header(path_to_file, response_body)
    #NOTE: This conditional was added for a Cob Spec test which is not passing. Not sure what the test is after
    if @relative_path == "/redirect"
      header_info = { "status_code" => set_response_message(200), "content_type" => find_content_type(path_to_file), "content_length" => response_body.length }
      location_info = ("location: http://localhost:5000/\r\n")
      create_response_header(header_info, location_info)
    else
      header_info = { "status_code" => set_response_message(200), "content_type" => find_content_type(path_to_file), "content_length" => response_body.length }
      create_response_header(header_info)
    end
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
      204 => "204 No Content",
      301 => "301 Moved Permanently",
      302 => "302 Moved Temporarily",
      304 => "304 Not Modified",
      400 => "400 Bad Request",
      401 => "401 Unauthorized",
      404 => "404 Not Found",
      405 => "405 Method Not Allowed",
      500 => "500 Internal Server Error"
    }
    response_messages[status_code]
  end

  def return_relative_path
    @relative_path
  end
end
