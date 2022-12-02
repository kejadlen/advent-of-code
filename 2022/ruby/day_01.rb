# p ARGF.read.split("\n\n").map { _1.each_line.map(&:to_i).sum }.max
p ARGF.read.split("\n\n").map { _1.each_line.map(&:to_i).sum }.sort[-3..-1].sum
