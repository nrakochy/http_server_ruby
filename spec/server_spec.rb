require 'server'
#require 'webmock'

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

end
