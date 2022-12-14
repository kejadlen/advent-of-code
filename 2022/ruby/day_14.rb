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

def cave.to_s
  x_min, x_max = keys.map(&:first).minmax
  y_min, y_max = keys.map(&:last).minmax

  (0..y_max+1).map {|y|
    (x_min-1..x_max+1).map {|x|
      self.fetch([x, y], ?.)
    }.join
  }.join("\n")
end

def pour_sand(cave, stop:)
  return enum_for(__method__, cave, stop:) unless block_given?

  loop do
    # puts cave
    pos = [500, 0]

    while next_pos = [0, -1, 1].map {|dx| pos.zip([dx, 1]).map { _1 + _2 }}.find { cave[_1].nil? }
      pos = next_pos
      break if stop.(*pos)
    end
    break if stop.(*pos)

    cave[pos] = ?o
    yield pos
  end
end

y_max = cave.keys.map(&:last).max

# part one
p pour_sand(cave, stop: ->(_, y) { y >= y_max }).count

# part two
cave.delete_if { _2 == ?o } # reset cave
cave.default_proc = ->(_,(_,y)) { y == y_max + 2 ? ?# : nil }
p pour_sand(cave, stop: ->(x, y) { [x, y] == [500, 0] }).count + 1
