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
      when  0 # keep going
      when  1 then return 1
      end
    end
    (left.size == right.size) ? 0 : -1
  else
    compare(Array(left), Array(right))
  end
end

# part one
pairs = ARGF.read.split("\n\n")
pairs = pairs.map {|pair| pair.lines(chomp: true).map { eval(_1) }}

p pairs.map.with_index
  .select {|(l,r),_| compare(l, r) == -1 }
  .sum { _1.last + 1 }

# part two
pairs = pairs.flatten(1)

dividers = [[[2]], [[6]]]
pairs.concat(dividers)
pairs = pairs.sort { compare(_1, _2) }
p dividers
  .map { pairs.index(_1) + 1 }
  .inject(:*)
