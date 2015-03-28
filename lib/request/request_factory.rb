require 'cgi'
require 'uri'
require 'activity_logger'

class RequestFactory

  def initialize(client)
    @client = client
    @logger = ActivityLogger.new
  end

  def read_request
    @client.readpartial(300)
  end

  def parse_request_by_category(request)
    split_req = split_request_by_line(request)
    first_line = split_req[0].split(" ")
    method = first_line[0]
    host = find_header_data(split_req, "Host:")
    range = find_header_data(split_req, "Range:")
    etag = find_header_data(split_req, "If-Match:")
    credentials = find_header_data(split_req, "Authorization:")
    uri = URI(first_line[1])
    query_params = find_query_params(uri)
    incoming_data = split_req.last.chomp
    { "method" => method, "uri" => uri,
      "incoming_data" => incoming_data, "host" => host,
      "credentials" => credentials, "query_params" => query_params,
      "range" => range, "etag" => etag }
  end

  def split_request_by_line(request)
    request.split("\r\n")
  end

  def find_header_data(request, header_label)
    info = get_header_info(request, header_label)
    !info.nil? ? strip_header_label(info) : nil
  end

  def get_header_info(request, header_label)
    header_data = request.select{|line| line.include?(header_label)}
    header_data.empty? ? nil : header_data.pop
  end

  def strip_header_label(header_info)
    split = header_info.split(" ")
    split.last
  end

  def find_query_params(uri)
    if uri.query.nil?
      nil
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

