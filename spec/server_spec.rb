require 'server'

describe HTTPServer do
  server = HTTPServer.new({ "hostname" => "::1", "port" => 5000 })

  describe "#closing_connection_message" do
    it "returns a string message with two new lines" do
      closing_connection = "Connection: close\r\n\r\n"
      expect(server.closing_connection_message).to eq(closing_connection)
    end
  end
end
