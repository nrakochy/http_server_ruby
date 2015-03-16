class ActivityLogger

  def initialize
    @public_dir = File.expand_path("../../public", __FILE__)
  end

  def log_server_activity(data)
    new_record = create_log_record(data)
    add_record_to_log(new_record)
  end

  def create_log_record(data)
    split_data = data.split("\r\n")
    split_data[0] + "\n"
  end

  def add_record_to_log(new_record)
    log_file = File.join(@public_dir, "/logs")
    File.open(log_file, "a"){ |file| file << new_record }
  end
end
