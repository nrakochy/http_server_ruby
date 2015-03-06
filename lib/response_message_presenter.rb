require 'io_stream'

class ResponseMessagePresenter

  def initialize(io = IOStream.new)
    @io = io
  end

  def server_started(host, port)
    @io.print_message("Server is started and listening on #{host.to_s} #{port.to_s}")
  end

  def build_response_message(response_body)
    header = create_response_header(response)
    @io.print_message(header + response_body + row_end)
  end

  def create_response_header(response)
    (response_status + set_timestamp + set_content_type +
      set_content_length(response) + close_msg)
  end

  def response_status(status_code = 200)
    "HTTP/1.1 " + status_code.to_s + row_end
  end

  def set_content_type(content_type = "application/octet-stream")
    "Content type: " + content_type + row_end
  end

  def set_timestamp
    "Date: " + Time.now.to_s + row_end
  end

  def close_msg
    "Connection: close" + row_end
  end

  def row_end
    "\r\n"
  end




end
