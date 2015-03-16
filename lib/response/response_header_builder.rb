class ResponseHeaderBuilder


  def create_response_header(response, additional_information ="")
    response = ("HTTP/1.1 #{response["status_code"]}\r\n" +
                "Date: #{Time.now.to_s}\r\n" +
    "Content-Type: #{response["content_type"]}\r\n" +
    "Content-Length: #{response["content_length"]}\r\n")
    response + additional_information
  end

  def set_response_message(status_code)
    response_messages = {
      200 => "200 OK",
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
end
