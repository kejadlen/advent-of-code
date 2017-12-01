# p ARGF.read.strip.chars.map(&:to_i).each_cons(2).select {|a,b| a == b }.map(&:first).sum

a = ARGF.read.strip.chars.map(&:to_i)
b = a.rotate(a.size/2)
p a.zip(b).select {|a,b| a == b }.map(&:first).sum
