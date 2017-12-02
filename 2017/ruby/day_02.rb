p ARGF.read.strip.split("\n")
  .map {|line| line.split("\t").map(&:to_i) }
  .map {|row| row.combination(2).map(&:sort).map(&:reverse).find {|a,b| (a.to_f / b.to_f) * 10 % 10 == 0 }}
  .map {|a,b| a / b}
  .sum
