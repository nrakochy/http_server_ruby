require 'server'

describe HTTPServer do

  let(:legit_post_req){ { "method" => "POST", "uri" => URI("/form"), "incoming_data" => "params1=value1" } }
  let(:basic_post_response){ ServerResponse.new(legit_post_req) }

  describe "#create_response_header" do
    it "returns a properly formatted HTTP response header" do
      response =
        { "status_code" => "200 OK", "content_type" => "text/html", "content_length" => "25" }
      expected_result =
        "HTTP/1.1 200 OK\r\n" +
        "Date: #{Time.now.to_s}\r\n" +
        "Content-Type: text/html\r\n" +
        "Content-Length: 25\r\n"
      expect(basic_post_response.create_response_header(response)).to eq(expected_result)
    end
  end

  describe "#legitimate_file_request?" do
    it 'returns false if requested file path is a directory' do
      filepath = File.expand_path("../", __FILE__)
      expect(basic_post_response.legitimate_file_request?(filepath)).to eq(false)
      expect(File.directory?(filepath)).to eq(true)
    end

    it 'returns false if requested file path leads to non-existing file' do
      filepath = File.expand_path("../non_existent.txt", __FILE__)
      expect(basic_post_response.legitimate_file_request?(filepath)).to eq(false)
    end

    it 'returns true if requested file exists' do
      filepath = File.expand_path("../../public/text-file.txt", __FILE__)
      expect(basic_post_response.legitimate_file_request?(filepath)).to eq(true)
    end
  end

  describe "#interpret_request" do
    it "returns a hash with properly formatted response_header and response body" do
      bogus_request = { "method" => "GET", "uri" => URI("/path/to/file/index.html"), "incoming_data" => "params1=value1" }
      expected_404_message = "File not found"
      expected_404_header = (
        "HTTP/1.1 404 Not Found\r\n" +
        "Date: #{Time.now.to_s}\r\n" +
        "Content-Type: text/plain\r\n" +
        "Content-Length: 14\r\n")
      expect(ServerResponse.new(bogus_request).interpret_request).to eq(
        { "header" => expected_404_header, "response_body" => expected_404_message })
    end
  end
end
