priorities = (?a..?z).chain(?A..?Z).each.with_index.to_h { [_1, _2+1] }
input = ARGF.read.lines(chomp: true).map(&:chars)

# part 1
p input.sum { priorities.fetch(_1.each_slice(_1.length/2).inject(&:&)[0]) }

# part 2
p input.each_slice(3).sum { priorities.fetch(_1.inject(&:&)[0]) }
