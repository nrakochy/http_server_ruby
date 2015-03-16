class FileAccessor

  def initialize
    @public_dir = File.expand_path("../../../public", __FILE__)
  end

  def read_file(full_path)
    File.open(full_path, "rb"){|file| file.read }
  end

  def write_file(full_path, data)
    File.open(full_path, "wb"){ |file| file.puts(data) }
  end

  def append_file(full_path, data)
    File.open(full_path, "a"){|file| file << data }
  end

  def list_directory
    list = []
    Dir.foreach(@public_dir){|file| list << file }
    list
  end

  def legitimate_request?(requested_file_path)
    root = File.join(@public_dir, "/")
    redirect = File.join(@public_dir, "/redirect")
    requested_file_path == root || requested_file_path == redirect ||
      (File.exists?(requested_file_path) && !File.directory?(requested_file_path))
  end



end
