require 'server'
require 'webmock'

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

  describe "#raise_404_error" do
    it "returns a hash with properly formatted response_header" do
      error = server.raise_404_error
      expected_404 = (
        "HTTP/1.1 404 Not Found\r\n" +
        "Date: #{Time.now.to_s}\r\n" +
        "Content-Type: text/plain\r\n" +
          "Content-Length: 14\r\n" +
          "Connection: close\r\n\r\n")
      expect(error["header"]).to eq(expected_404)
    end
  end

  describe "#set_response_message" do
    it "returns the HTTP message based on the status code" do
      expect(server.set_response_message("200")).to eq("OK")
      expect(server.set_response_message("500")).to eq("Internal Server Error")
    end

    it "returns 'Not Found' by default" do
      expect(server.set_response_message(800)).to eq("Not Found")
    end
  end

  describe "#create_response_header" do
    it "returns a properly formatted HTTP response header" do
      response =
        { "status_code" => "200 OK", "content_type" => "text/html", "content_length" => "25" }
      expected_result =
        "HTTP/1.1 200 OK\r\n" +
        "Date: #{Time.now.to_s}\r\n" +
      "Content-Type: text/html\r\n" +
        "Content-Length: 25\r\n" +
        "Connection: close\r\n" +
        "\r\n"
      expect(server.create_response_header(response)).to eq(expected_result)
    end
  end

  describe "#legitimate_file_request?" do
    it 'returns false if requested file path is a directory' do
      filepath = File.expand_path("../", __FILE__)
      expect(server.legitimate_file_request?(filepath)).to eq(false)
      expect(File.directory?(filepath)).to eq(true)
    end

    it 'returns false if requested file path leads to non-existing file' do
      filepath = File.expand_path("../non_existent.txt", __FILE__)
      expect(server.legitimate_file_request?(filepath)).to eq(false)
    end

    it 'returns true if requested file exists' do
      filepath = File.expand_path("../../public/text-file.txt", __FILE__)
      expect(server.legitimate_file_request?(filepath)).to eq(true)
    end
  end


end
