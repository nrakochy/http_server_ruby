require 'socket'
require 'uri'
require 'thread'
require 'request/request_factory'
require 'request/request_router'
require 'activity_logger'

class HTTPServer
  NUM_WORKERS = 25

  def initialize(params)
    @server = TCPServer.new(params["hostname"], params["port"])
    @logger = ActivityLogger.new
    @jobs = Queue.new
  end

  def run
    loop {
      run_threads
    }
    @server.close_write
  end

  def run_threads
    workers = []
    NUM_WORKERS.times do |worker|
      workers << Thread.start do
        while @jobs << @server.accept
          serve(@jobs.pop)
        end
      end
    end
    workers.each(&:join)
  end


  def serve(client)
    parsed_request = handle_incoming_request(client)
    response = create_server_response(parsed_request)
    response_message = response["header"] + closing_connection_message + response["response_body"]
    log_activity(response["header"])
    client.print(response_message)
  ensure
    client.close_read
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

