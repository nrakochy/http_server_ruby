class RequestHandler

  def initialize(client)
    @client = client
  end

  def read_request
    @client.readpartial(1000)
  end

  def process_request(request)
    split_req = request.split("\n")
    first_line = split_req[0].split(" ")
    method = first_line[0]
    uri = URI(first_line[1])
    incoming_data = split_req.last
    { "method" => method, "uri" => uri, "incoming_data" => incoming_data }
  end
end
