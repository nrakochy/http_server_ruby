require 'server'

describe HTTPServer do
  let(:server){ HTTPServer.new({ hostname: "localhost", port: 5000 }) }

  describe "#legitimate_file_request?" do
    it 'returns false if requested file path is a directory' do
      filepath = File.expand_path("../", __FILE__)
      p filepath
      expect(server.legitimate_file_request?(filepath)).to eq(false)
      expect(File.directory?(filepath)).to eq(true)
    end

    it 'returns false if requested file path leads to non-existing file' do
      filepath = File.expand_path("../public/non_existent.txt", __FILE__)
      expect(server.legitimate_file_request?(filepath)).to eq(false)
    end

    it 'returns true if requested file exists' do
      filepath = File.expand_path("../../public/text-file.txt", __FILE__)
      expect(server.legitimate_file_request?(filepath)).to eq(true)
    end
  end
end
