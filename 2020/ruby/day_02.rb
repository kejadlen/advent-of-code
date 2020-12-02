p ARGF.read.scan(/(\d+)-(\d+)\s*(\w):\s*(\w+)/)
  .map {|a,b,c,d| [a.to_i, b.to_i, c, d] }
  # .count {|min,max,char,pass| (min..max).cover?(pass.count(char)) }
  .count {|p1,p2,char,pass| [pass[p1-1], pass[p2-1]].tally[char] == 1 }
