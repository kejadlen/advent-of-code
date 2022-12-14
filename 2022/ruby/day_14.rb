scan = ARGF.read.lines(chomp: true)

cave = scan.each.with_object({}) {|line, cave|
  line.split(" -> ")
    .map { _1.split(?,).map(&:to_i) }
    .each_cons(2) {|(ax,ay),(bx,by)|
      Range.new(*[ax, bx].sort).each do |x|
        Range.new(*[ay, by].sort).each do |y|
          cave[[x, y]] = ?#
        end
      end
    }
}

x_min, x_max = cave.keys.map(&:first).minmax
y_min, y_max = cave.keys.map(&:last).minmax

inspect_cave = -> {
  puts (0..y_max+1).map {|y|
    (x_min-1..x_max+1).map {|x|
      cave[[x, y]] || ?.
    }.join
  }.join("\n")
}

# part one
# sands = 0
# loop do
#   inspect_cave.()
#   sands += 1

#   pos = [500, 0]
#   while next_pos = [0, -1, 1].map {|dx| pos.zip([dx, 1]).map { _1 + _2 }}.find { cave[_1].nil? }
#     pos = next_pos
#     break if pos[1] >= y_max
#   end
#   break if pos[1] >= y_max

#   cave[pos] = ?o
# end

# inspect_cave.()
# p sands-1

# part two
cave.default_proc = ->(h,(x,y)) { h[[x, y]] = y == y_max + 2 ? ?# : nil }
sands = 0
loop do
  # inspect_cave.()
  sands += 1

  pos = [500, 0]
  while next_pos = [0, -1, 1].map {|dx| pos.zip([dx, 1]).map { _1 + _2 }}.find { cave[_1].nil? }
    pos = next_pos
  end
  break if pos == [500, 0]

  cave[pos] = ?o
end

inspect_cave.()
p sands
