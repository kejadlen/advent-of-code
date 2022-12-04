p ARGF.read
  .scan(/(\d+)-(\d+),(\d+)-(\d+)/)
  .map { _1.map(&:to_i) }
  .map {|a,b,c,d| [(a..b), (c..d)] }
  # .count {|a,b| a.cover?(b) || b.cover?(a) } # part 1
  .count {|a,b| a.minmax.any? { b.cover?(_1) } || b.minmax.any? { a.cover?(_1) }}
