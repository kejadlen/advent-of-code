def compare(left, right)
  case [left, right]
  in [left, nil]
    1
  in [Integer, Integer]
    left <=> right
  in [Array, Array]
    left.zip(right).each do |left, right|
      case compare(left, right)
      when -1 then return -1
      when 0 # no-op
      when 1 then return 1
      end
    end
    (left.size == right.size) ? 0 : -1
  else
    compare(Array(left), Array(right))
  end
end

# part one
# pairs = ARGF.read.split("\n\n")
# pairs = pairs.map {|pair| pair.lines(chomp: true).map { eval(_1) }}

# p pairs.map.with_index {|(left,right),i|
#   [compare(left, right), i+1]
# }.select {|cmp,_| cmp == -1 }.sum(&:last)

# part two
pairs = ARGF.read.lines(chomp: true).reject(&:empty?).map { eval(_1) }
pairs << [[2]] << [[6]]
pairs = pairs.sort { compare(_1, _2) }
a = pairs.index([[2]])
b = pairs.index([[6]])
p (a+1)*(b+1)
