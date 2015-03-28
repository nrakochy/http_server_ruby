class FileAccessor

  def initialize
    @public_dir = File.expand_path("../../../public", __FILE__)
    update_directory_list
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

  def patch_records(path_to_file, existing_records, updated_record)
    if existing_records.chomp.empty?
      formatted_record = format_single_record(updated_record)
      write_file(path_to_file, formatted_record)
    else
      updated_records = patch_record_update(existing_records, updated_record)
      formatted_records = format_records(updated_records)
      puts "FORMATTED RECORDS: #{formatted_records}"
      write_file(path_to_file, formatted_records)
    end
  end

  def update_directory_list
    directory_list = find_files_in_public_directory
    wrapped_list = wrap_in_html(directory_list)
    directory_path = File.join(@public_dir, "/index.html")
    write_file(directory_path, wrapped_list)
  end

  def find_files_in_public_directory
    list = []
    Dir.foreach(@public_dir){|file| list << file }
    list
  end

  def wrap_in_html(data)
    data.map{|record| '<a href=' + record + ">" + record + "</a>"}
  end

  def legitimate_request?(requested_file_path)
    root = File.join(@public_dir, "/")
    redirect = File.join(@public_dir, "/redirect")
    requested_file_path == root || requested_file_path == redirect ||
      (File.exists?(requested_file_path) && !File.directory?(requested_file_path))
  end

  def matching_etag?(path_to_file, updated_record)
    existing_record = existing_patch_record(path_to_file)
    updated_record["etag"] == existing_record.first
  end

  def existing_patch_record(path_to_file)
      existing_data = read_file(path_to_file)
      existing_data.split("\n")
  end

  def patch_record(path_to_file, updated_record)
    formatted_record = "#{updated_record["etag"]}\n#{updated_record["data"]}\n"
    write_file(path_to_file, formatted_record)
  end

end
