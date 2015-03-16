require 'uri'
require 'request_factory'

describe RequestFactory do
  let(:mock_io){ "mocked_out" }
  let(:factory){ RequestFactory.new(mock_io) }
  let(:sample_request){
    "POST /path/form?variable1=Operators%2 HTTP/1.0" +
    "From: someuser@example.com"    +
    "User-Agent: HTTPTool/1.0"      +
    "\r\n"                          +
    "data=fatcat"
  }

  describe "#parse_request_by_category" do
    it "returns a Hash with the incoming method request" do
      processed_request = factory.parse_request_by_category(sample_request)
      expect(processed_request["method"]).to eq("POST")
    end

    it "returns a Hash with the incoming uri" do
      processed_request = factory.parse_request_by_category(sample_request)
      path = processed_request["uri"].path
      expect(path).to eq("/path/form")
    end

    it "returns a Hash with the incoming uri" do
      processed_request = factory.parse_request_by_category(sample_request)
      expect(processed_request["incoming_data"]).to eq("data=fatcat")
    end

    it "returns a Hash with the query params" do
      processed_request = factory.parse_request_by_category(sample_request)
      expect(processed_request["query_params"]).to eq("variable1 = Operators%2\n")
    end

  end


  describe "#find_query_params" do
    it "returns an empty string if there are no params on the incoming request" do
      uri = URI("/form")
      expect(factory.find_query_params(uri)).to eq("")
    end

    it "returns a single query string from an incoming request" do
      uri = URI("/form?variable_1=Operators%2")
      expect(factory.find_query_params(uri)).to eq("variable_1 = Operators%2\n")
    end

    it "returns a single query string from an incoming request" do
      uri = URI("/form?variable_1=Operators%2&variable_2=Operators%7")
      expect(factory.find_query_params(uri)).to eq(
        "variable_1 = Operators%2\nvariable_2 = Operators%7\n")
    end

  end

  describe "#convert_query_to_string" do
    it "returns a strings with format param=query from single query" do
      query = { "variable_1" => ["Operators%2"] }
      expect(factory.convert_queries_to_string(query)).to eq("variable_1 = Operators%2\n")
    end

    it "returns a strings with format param=query from multiple queries" do
      query = { "variable_1" => ["Operators%2"], "variable_2" =>["Operators%3"] }
      expect(factory.convert_queries_to_string(query)).to eq("variable_1 = Operators%2\nvariable_2 = Operators%3\n")
    end
  end


end
