require 'server'
require 'webmock'

describe HTTPServer do
  server = HTTPServer.new({ hostname: "localhost", port: 5000 })

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

  describe "#split_http_request" do
    it 'returns an array which splits the HTTP req by space' do
      request = "GET /path/to/file/index.html HTTP/1.0"
      expect(server.split_http_request(request)).to eq(["GET", "/path/to/file/index.html", "HTTP/1.0"])
    end

    it 'returns an array which splits multi-line http request' do
      request = "GET /path/to/file/index.html HTTP/1.0 \n MORE interesting    data"
      expect(server.split_http_request(request)).to eq(
        ["GET", "/path/to/file/index.html", "HTTP/1.0", "MORE", "interesting", "data"])
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
      code = "200"
      type = "text/html"
      length = 25
      expected_result =
        "HTTP/1.1 200 OK\r\n" +
        "Date: #{Time.now.to_s}\r\n" +
        "Content-Type: text/html\r\n" +
        "Content-Length: 25\r\n" +
        "Connection: close\r\n" +
        "\r\n"
      expect(server.create_response_header(code, type, length)).to eq(expected_result)
    end
  end
end
