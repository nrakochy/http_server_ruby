require 'cgi'

class IOStream
  def initialize(io = CGI.new)
    @io = io
  end

  def print_message(message)
    @io.puts(message)
  end

  def row_end
    "\r\n"
  end
end
