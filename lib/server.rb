require 'socket'
require 'uri'
require 'request_handler'
require 'response_handler'

class HTTPServer

  def initialize(params)
    @server = TCPServer.new(params["hostname"], params["port"])
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
    header = response["header"]
    response_body = response["response_body"]
    client.print(header)
    client.print(closing_connection_message)
    client.print(response_body) if !response_body.empty?
  ensure
    client.close
  end

  def create_server_response(request)
    ResponseHandler.new(request).interpret_request
  end

  def handle_incoming_request(client)
    handler = RequestHandler.new(client)
    http_request = handler.read_request
    STDERR.puts(http_request)
    handler.process_request(http_request)
  end

  def closing_connection_message
    "Connection: close\r\n\r\n"
  end
end

