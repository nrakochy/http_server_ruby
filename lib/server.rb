require 'socket'
require 'uri'
require 'request/request_factory'
require 'request/request_router'
require 'activity_logger'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params["hostname"], params["port"])
    @logger = ActivityLogger.new
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
    parsed_request = handle_incoming_request(client)
    response = create_server_response(parsed_request)
    response_message = response["header"] + closing_connection_message + response["response_body"]
    log_activity(response["header"])
    client.print(response_message)
  ensure
    client.close
  end

  def create_server_response(request)
    RequestRouter.new(request).authenticate_and_route
  end

  def handle_incoming_request(client)
    handler = RequestFactory.new(client)
    http_request = handler.read_request
    log_activity(http_request)
    STDERR.puts(http_request)
    handler.parse_request_by_category(http_request)
  end

  def log_activity(data)
    @logger.log_server_activity(data)
  end

  def closing_connection_message
    "Connection: close\r\n\r\n"
  end
end

