require 'server'

describe HTTPServer do
  let(:server){ HTTPServer.new({ hostname: "localhost", port: 5000 }) }
  describe "#legitimate_file_request?" do
    it 'returns false if requested file path is a directory' do
      filepath = File.expand_path("../", __FILE__)
      expect(server.legitimate_file_request?(filepath)).to eq(false)
      expect(File.directory?(filepath)).to eq(true)
    end
  end
end
