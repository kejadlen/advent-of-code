blacklist = ARGF.read.split("\n").map {|line| Range.new(*line.split(?-).map(&:to_i)) }

ip = 0
count = 0
until ip > 4294967295
  range = blacklist.find {|range| range.cover?(ip) }
  if range.nil?
    count += 1
    ip += 1
  else
    ip = range.end + 1
  end
end
puts count
