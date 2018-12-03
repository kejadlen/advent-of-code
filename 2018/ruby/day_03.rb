p ARGF.read.lines.each.with_object(Hash.new(0)) {|line, fabric|
  line =~ /(\d+),(\d+): (\d+)x(\d+)$/
  x = $1.to_i
  y = $2.to_i
  width = $3.to_i
  height = $4.to_i

  width.times {|dx|
    height.times {|dy|
      fabric[[y + dy, x + dx]] += 1
    }
  }
}.count {|_,v| v > 1 }
