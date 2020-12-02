n = 3
x = ARGF.read.split.map(&:to_i).combination(n).find {|x| x.sum == 2020 }
p x.reduce(&:*)
