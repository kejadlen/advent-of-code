priorities = ((?a..?z).to_a + (?A..?Z).to_a).map.with_index { [_1, _2+1]  }.to_h

# part 1
# p ARGF.read.lines(chomp: true).map {|line|
#   len = line.length
#   a = line[0...len/2]
#   b = line[len/2..]
#   priorities.fetch((a.chars & b.chars)[0])
# }.sum

p ARGF.read.lines(chomp: true).each_slice(3).map {|chunk|
  priorities.fetch(chunk.map(&:chars).inject(&:&)[0])
}.sum
