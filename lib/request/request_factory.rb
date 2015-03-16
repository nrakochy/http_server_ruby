require 'cgi'
require 'uri'

class RequestFactory

  def initialize(client)
    @client = client
  end

  def read_request
    @client.readpartial(1000)
  end

  def parse_request_by_category(request)
    split_req = split_request_by_line(request)
    first_line = split_req[0].split(" ")
    method = first_line[0]
    host = find_header_info(split_req, "Host")
    credentials = find_header_info(split_req, "Authentication")
    uri = URI(first_line[1])
    query_params = find_query_params(uri)
    incoming_data = split_req.last.chomp
    { "method" => method, "uri" => uri,
      "incoming_data" => incoming_data, "host" => host,
      "credentials" => credentials, "query_params" => query_params }
  end

  def find_header_info(request, header_info)
    header = request.select{|line| line.include?(header_info)}
    header.pop
  end

  def split_request_by_line(request)
    request.split("\r\n")
  end

  def find_query_params(uri)
    if uri.query.nil?
      ""
    else
      params = CGI::parse(uri.query)
      convert_queries_to_string(params)
    end
  end

  def convert_queries_to_string(queries)
    results = queries.map do |key, value|
      combined = value.join(" ")
      "#{key} = #{combined}\n"
    end
    results.join('')
  end


end

