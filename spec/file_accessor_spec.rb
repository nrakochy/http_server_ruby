require 'response/file_accessor'

describe FileAccessor do
    let(:file_accessor){ FileAccessor.new }

    describe "#legitimate_request?" do
      it 'returns false if requested file path is a directory' do
        filepath = File.expand_path("../", __FILE__)
        expect(file_accessor.legitimate_request?(filepath)).to eq(false)
        expect(File.directory?(filepath)).to eq(true)
      end

      it 'returns false if requested file path leads to non-existing file' do
        filepath = File.expand_path("../non_existent.txt", __FILE__)
        expect(file_accessor.legitimate_request?(filepath)).to eq(false)
      end

      it 'returns true if requested file path is the root directory' do
        filepath = File.expand_path("../../public", __FILE__)
        root = File.join(filepath, "/")
        expect(file_accessor.legitimate_request?(root)).to eq(true)
        expect(File.directory?(filepath)).to eq(true)
      end

      it 'returns true if requested file exists' do
        filepath = File.expand_path("../../public/text-file.txt", __FILE__)
        expect(file_accessor.legitimate_request?(filepath)).to eq(true)
      end
    end

    describe "#wrap_in_html" do
      it "returns an array of input data wrapped in hyperlink tags" do
        list = ["record1", "record2"]
        expect(file_accessor.wrap_in_html(list)).to eq(
        ["<a href=record1>record1</a>", "<a href=record2>record2</a>"])
      end
    end

    describe "#find_files_in_public_directory" do
      it "returns a list of files in the public directory" do
        list = []
        Dir.foreach(File.expand_path("../../public", __FILE__)){|file| list << file }
        expect(file_accessor.find_files_in_public_directory).to eq(list)
      end
    end
end
