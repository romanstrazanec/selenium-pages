# frozen_string_literal: true

read_stream, write_stream = IO.pipe

Process.fork do
  require_relative 'fabfilter'

  fabfilter = FabFilter.new
  # Thread.current[:output] = fabfilter.get_price
  write_stream.puts fabfilter.get_price
end

Process.fork do
  require_relative 'oeksound'

  oeksound = OEKSound.new
  write_stream.puts oeksound.get_price
end

Process.fork do
  require_relative 'neuraldsp'

  neuraldsp = NeuralDSP.new
  write_stream.puts neuraldsp.get_price
end

Process.fork do
  require_relative 'umanskybass'

  umanskybass = UmanskyBass.new
  write_stream.puts umanskybass.get_price
end

Process.waitall
write_stream.close
results = read_stream.read
puts results
read_stream.close
