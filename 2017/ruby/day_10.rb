list = (0..255).to_a
current = 0
# lengths = ARGF.read.strip.split(?,).map(&:to_i)
input = ARGF.read.strip
p input
lengths = input.split(//).map(&:ord)
p lengths
lengths.concat([17, 31, 73, 47, 23])
skip = 0

# list = (0..4).to_a
# lengths = [3,4,1,5]

64.times do
  lengths.each do |length|
    list[0, length] = list[0, length].reverse
    list = list.rotate(length + skip)
    current += length + skip
    current %= list.size
    skip += 1

    # p list.rotate(list.size - current)
  end
end

list = list.rotate(list.size - current)
p list
dense = list.each_slice(16).map {|slice| slice.inject(&:^) }
p dense
p hex = dense.map {|n| n.to_s(16).rjust(2, ?0) }.join

# list = list.rotate(list.size - current)
# p list[0] * list[1]
