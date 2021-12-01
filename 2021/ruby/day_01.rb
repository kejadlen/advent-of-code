p ARGF.read.split("\n").map(&:to_i).each_cons(2).count {|x,y| x < y }
p ARGF.read.split("\n").map(&:to_i).each_cons(3).map(&:sum).each_cons(2).count {|x,y| x < y }
