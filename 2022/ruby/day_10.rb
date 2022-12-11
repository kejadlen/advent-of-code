instructions = ARGF.read.lines(chomp: true)

def exec(instructions)
  return enum_for(__method__, instructions) unless block_given?

  x = 1
  instructions.each do |instruction|
    case instruction
    when /noop/
      yield x
    when /addx (-?\d+)/
      yield x
      yield x
      x += $1.to_i
    else
      fail "invalid instruction: #{instruction}"
    end
  end
  yield x
end

x_hist = exec(instructions).to_a

# part one
p 20.step(by: 40, to: 220).sum { x_hist[_1-1] * _1 }

# part two
puts x_hist.each_slice(40).map {|row|
  row.each.with_index.map {|x, cycle|
    (-1..1).cover?(cycle - x) ? ?# : ?.
  }.join
}.join("\n")

# a functional version of part two, but I think
# the imperative version feels closer to the domain
#
# x_hist.each_slice(40) do |row|
#   row.each.with_index do |x, cycle|
#     putc (-1..1).cover?(cycle - x) ? ?# : ?.
#   end
#   puts
# end
