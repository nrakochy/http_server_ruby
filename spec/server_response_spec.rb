require 'server'

describe ServerResponse do

  let(:legit_post_req){ { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2"), "incoming_data" => "params1=value1" } }
  let(:basic_post_response){ ServerResponse.new(legit_post_req) }

  context "Interpretation Methods: #get / #head" do
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

      it 'returns true if requested file path is the root directory' do
        filepath = File.expand_path("../../public", __FILE__)
        root = File.join(filepath, "/")
        expect(basic_post_response.legitimate_file_request?(root)).to eq(true)
        expect(File.directory?(filepath)).to eq(true)
      end

      it 'returns true if requested file exists' do
        filepath = File.expand_path("../../public/text-file.txt", __FILE__)
        expect(basic_post_response.legitimate_file_request?(filepath)).to eq(true)
      end
    end
  end

  context "Response Builder Methods" do
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

    describe "#raise_error" do
      it "returns a hash with header and response_body based on status code with
        status code as response_body if no message given" do
        error = basic_post_response.raise_error(404)
        expected_header =
          "HTTP/1.1 404 Not Found\r\n" +
          "Date: #{Time.now.to_s}\r\n" +
        "Content-Type: text/plain\r\n" +
          "Content-Length: 14\r\n"
        expect(error["header"]).to eq(expected_header)
        expect(error["response_body"]).to eq("404 Not Found ")
      end

      it "returns a hash with header and response_body based on status code with
        status code + message given as response_body" do
        error = basic_post_response.raise_error(404, "File not found")
        expected_header =
          "HTTP/1.1 404 Not Found\r\n" +
          "Date: #{Time.now.to_s}\r\n" +
        "Content-Type: text/plain\r\n" +
          "Content-Length: 28\r\n"
        expect(error["header"]).to eq(expected_header)
        expect(error["response_body"]).to eq("404 Not Found File not found")
      end
    end
  end

  context "HTTP Response methods" do
    describe "#interpret_request" do
      it "returns a hash with properly formatted response_header and response body" do
        bogus_request = { "method" => "GET", "uri" => URI("/path/to/file/index.html"), "incoming_data" => "params1=value1" }
        expected_404_message = "404 Not Found File not found"
        expected_404_header = (
          "HTTP/1.1 404 Not Found\r\n" +
          "Date: #{Time.now.to_s}\r\n" +
          "Content-Type: text/plain\r\n" +
            "Content-Length: 28\r\n")
        expect(ServerResponse.new(bogus_request).interpret_request).to eq(
          { "header" => expected_404_header, "response_body" => expected_404_message })
      end
    end
  end
  context "Helper Methods" do
    describe "#find_query_params" do
      it "returns a hash of query parameters from a URI with parameters" do
        post_req = { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2"), "incoming_data" => "params1=value1" }
        queried = ServerResponse.new(post_req).find_query_params
        expect(queried).to eq(" variable_1 = Operators%2\n")
      end

      it "returns a hash of query parameters from a URI with parameters" do
        post_req = { "method" => "POST", "uri" => URI("/form"), "incoming_data" => "params1=value1" }
        queried = ServerResponse.new(post_req).find_query_params
        expect(queried).to eq("")
      end
    end

    describe "#convert_query_to_string" do
      it "returns a strings with format param=query from single query" do
        post_req = { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2"), "incoming_data" => "params1=value1" }
        response = ServerResponse.new(post_req)
        query = { "variable_1" => ["Operators%2"] }
        expect(response.convert_queries_to_string(query)).to eq(" variable_1 = Operators%2\n")
      end

      it "returns a strings with format param=query from multiple queries" do
        post_req = { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2variable_2=Operators%3"), "incoming_data" => "params1=value1" }
        response = ServerResponse.new(post_req)
        query = { "variable_1" => ["Operators%2"], "variable_2" =>["Operators%3"] }
        expect(response.convert_queries_to_string(query)).to eq(" variable_1 = Operators%2\n variable_2 = Operators%3\n")
      end

      describe "#check_for_redirect" do
        it "redefines a redirect route with the root route" do
          post_req = { "method" => "POST", "uri" => URI("/redirect"), "incoming_data" => "params1=value1" }
          response = ServerResponse.new(post_req)
          expect(response.check_for_redirect(post_req["uri"])).to eq("/")
        end
      end
    end
  end
end
