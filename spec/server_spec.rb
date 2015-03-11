require 'server'

describe HTTPServer do
  server = HTTPServer.new({ "hostname" => "::1", "port" => 5000 })

  describe "#split_request" do
    it 'returns a hash with method and uri from a one-line HTTP req by space' do
      request = "GET /path/to/file/index.html HTTP/1.0"
      expect(server.split_request(request)).to eq(
        { "method" => "GET", "uri" => URI("/path/to/file/index.html"), "incoming_data" => "GET /path/to/file/index.html HTTP/1.0" })
    end

    it 'returns a hash with method /uri/ and incoming_data from a one-line HTTP req by space' do
      request = "GET /path/to/file/index.html HTTP/1.0\nparams1=value1"
      expect(server.split_request(request)).to eq(
        { "method" => "GET", "uri" => URI("/path/to/file/index.html"), "incoming_data" => "params1=value1" })
    end

  end

  describe "#closing_connection_message" do
    it "returns a string message with two new lines" do
      closing_connection = "Connection: close\r\n\r\n"
      expect(server.closing_connection_message).to eq(closing_connection)
    end
  end
end
