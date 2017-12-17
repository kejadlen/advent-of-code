input = ARGF.read.strip.to_i
# input = 3

# buffer = [0]
pos = 0
50_000_000.times do |i|
# 10.times do |i|
  pos += input + 1
  # pos %= buffer.size
  pos %= i + 1

  p i+1 if pos.zero?

  # buffer = (buffer[0..pos] << i+1).concat(buffer[pos+1..-1])
end

# index = buffer.index(0)
# p buffer[index+1]

# So 0 is always element 0...
# So we just need to know when something is inserted at element 1?
