instructions = ARGF.read.lines(chomp: true)

adds = {}
cycle = 1
instructions.each do |instruction|
  cycle += case instruction
           when /noop/
             1
           when /addx (-?\d+)/
             adds[cycle+1] = $1.to_i
             2
           else fail instruction
           end
end

xs = (0..adds.keys.max).inject([1]) { _1 << _1.last + adds.fetch(_2, 0) }
p 20.step(by: 40, to: 220).map { [_1, xs[_1]] }.sum { _1 * _2 }

puts 6.times.map {|y|
  40.times.map {|x|
    cycle = 40*y + x + 1
    xx = xs.fetch(cycle, xs.last)
    (-1..1).cover?(x - xx) ? ?# : ?.
  }.join
}.join("\n")
