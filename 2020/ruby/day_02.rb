day1 = proc {|min,max,char,pass| (min..max).cover?(pass.count(char)) }
day2 = proc {|p1,p2,char,pass| [pass[p1-1], pass[p2-1]].count(char) == 1 }
puts ARGF.read.scan(/^(\d+)-(\d+)\s*(\w):\s*(\w+)$/)
  .map {|a,b,c,d| [a.to_i, b.to_i, c, d] }
  .count(&day2)
