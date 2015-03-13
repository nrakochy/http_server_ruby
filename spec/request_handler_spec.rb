require 'uri'
require 'request_handler'

describe RequestHandler do
  let(:mock_io){ "mocked_out" }
  let(:handler){ RequestHandler.new(mock_io) }
  let(:sample_request){
    "POST /path/file.html HTTP/1.0" +
    "From: someuser@example.com"    +
    "User-Agent: HTTPTool/1.0"      +
    "\r\n"                          +
    "data=fatcat"
  }

  describe "#process_request" do
    it "returns a Hash with the incoming method request" do
      processed_request = handler.process_request(sample_request)
      expect(processed_request["method"]).to eq("POST")
    end

    it "returns a Hash with the incoming uri" do
      processed_request = handler.process_request(sample_request)
      path = processed_request["uri"].path
      expect(path).to eq("/path/file.html")
    end

    it "returns a Hash with the incoming uri" do
      processed_request = handler.process_request(sample_request)
      expect(processed_request["incoming_data"]).to eq("data=fatcat")
    end
  end

end
