require 'socket'
require 'uri'
require 'server_response'

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
    http_request = retrieve_request(client)
    STDERR.puts(http_request)
    split_request = split_request(http_request)
    response = create_server_response(split_request)
    header = response["header"]
    response_body = response["response_body"]
    client.print(header)
    client.print(closing_connection_message)
    client.print(response_body) if !response_body.empty?
  ensure
    client.close
  end

  def retrieve_request(client)
    client.readpartial(1000)
  end

  def split_request(request)
    split_req = request.split("\n")
    first_line = split_req[0].split(" ")
    method = first_line[0]
    uri = URI(first_line[1])
    incoming_data = split_req.last
    { "method" => method, "uri" => uri, "incoming_data" => incoming_data }
  end

  def create_server_response(request)
    ServerResponse.new(request).interpret_request
  end

  def closing_connection_message
    "Connection: close\r\n\r\n"
  end
end

