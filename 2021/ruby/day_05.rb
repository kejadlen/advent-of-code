vents = ARGF.read.split("\n").map {|l| l.split(" -> ").map {|x| x.split(?,).map(&:to_i) }}

straights = vents.select {|(x1,y1),(x2,y2)| x1 == x2 || y1 == y2 }

points = Hash.new(0)
straights.each do |(x1,y1),(x2,y2)|
  x = [x1, x2].minmax
  y = [y1, y2].minmax
  (x[0]..x[1]).each do |x|
    (y[0]..y[1]).each do |y|
      points[[x,y]] += 1
    end
  end
end

diagonals = vents - straights
diagonals.each do |(x1,y1),(x2,y2)|
  if x1 > x2
    x1,x2 = x2,x1
    y1,y2 = y2,y1
  end
  sign = (y1 < y2) ? 1 : -1
  (x1..x2).each.with_index do |x,i|
    delta = i * sign
    points[[x,y1+delta]] += 1
  end
end

p points.count {|_,v| v > 1 }
