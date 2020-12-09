N = 25

data = ARGF.read.scan(/\d+/).map(&:to_i)

invalid = data.each_cons(N+1).filter_map {|range|
  n = range.pop
  range.combination(2).map(&:sum).include?(n) ? nil : n
}.first

weakness = (0..).lazy.flat_map {|start|
  (2..data.size-start-1).map {|len|
    data[start, len]
  }
}.find {|range|
  range.sum == invalid
}.minmax.sum

p weakness
