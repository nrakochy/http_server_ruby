class IOStream
  def initialize(input = $stdin, output = $stdout)
    @input = input
    @output = output
  end

  def print_message(message)
    @output.puts(message)
  end

  def row_end
    "\r\n"
  end
end
