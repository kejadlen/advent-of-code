a = ARGF.read.lines.map(&:chomp).map(&:chars)
# two = a.count {|i| i.any? {|x| i.count(x) == 2} }
# three = a.count {|i| i.any? {|x| i.count(x) == 3} }
# puts two * three
x,y = a.flat_map {|i|
  a.select {|j|
    i.zip(j).select {|a,b| a != b }.count == 1
  }
}.map(&:join)

p x.chars.zip(y.chars).select {|a,b| a == b }.map(&:first).join
