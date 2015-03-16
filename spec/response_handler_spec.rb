require 'response/response_handler'

describe ResponseHandler do

  let(:legit_post_req){ { "method" => "POST", "uri" => URI("/form?variable_1=Operators%2"), 
    "query_params" => "", "incoming_data" => "params1=value1" } }
  let(:basic_post_response){ ResponseHandler.new(legit_post_req) }

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
      xit "returns a hash with properly formatted response_header and response body" do
        bogus_request = { "method" => "GET", "uri" => URI("/path/to/file/index.html"), "incoming_data" => "params1=value1" }
        expected_404_message = "404 Not Found File not found"
        expected_404_header = (
          "HTTP/1.1 404 Not Found\r\n" +
          "Date: #{Time.now.to_s}\r\n" +
          "Content-Type: text/plain\r\n" +
            "Content-Length: 28\r\n")
        expect(ResponseHandler.new(bogus_request).interpret_request).to eq(
          { "header" => expected_404_header, "response_body" => expected_404_message })
      end
    end
  end
  context "Helper Methods" do
    describe "#serve_file_path" do
      it "returns a path to a root file" do
        post_req = { "method" => "POST", "uri" => URI("/"), "incoming_data" => "params1=value1" }
        response = ResponseHandler.new(post_req)
        filepath = File.expand_path("../../public", __FILE__)
        homepage = File.join(filepath, "/index.html")
        expect(response.serve_file_path(response.return_relative_path)).to eq(homepage)
      end

      it "redefines a redirect route to a given file" do
        post_req = { "method" => "POST", "uri" => URI("/redirect"), "incoming_data" => "params1=value1" }
        response = ResponseHandler.new(post_req)
        filepath = File.expand_path("../../public", __FILE__)
        homepage = File.join(filepath, "/index.html")
        expect(response.serve_file_path(response.return_relative_path)).to eq(homepage)
      end
    end
  end
end
