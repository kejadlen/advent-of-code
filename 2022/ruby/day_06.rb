# p ARGF.read.chars.each_cons(4).with_index.find {|a,i| a.uniq.size == 4 }.last + 4
p ARGF.read.chars.each_cons(14).with_index.find {|a,i| a.uniq.size == 14 }.last + 14
