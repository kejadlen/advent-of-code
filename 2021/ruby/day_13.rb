dots, folds = ARGF.read.split("\n\n")

dots = dots.scan(/(\d+),(\d+)/).map { _1.map(&:to_i) }
folds = folds.scan(/(x|y)=(\d+)/).map { [_1, _2.to_i] }

folds.each do |dir, axis|
  case dir
  when ?x
    dots.select {|x,y| x > axis }.each do |dot|
      dot[0] = axis - (dot[0] - axis)
    end
  when ?y
    dots.select {|x,y| y > axis }.each do |dot|
      dot[1] = axis - (dot[1] - axis)
    end
  else
    fail
  end
  dots.uniq!
  # p dots.size or exit
end

xx = Range.new(*dots.map(&:first).minmax)
yy = Range.new(*dots.map(&:last).minmax)
puts yy.map {|y| xx.map {|x| dots.include?([x,y]) ? "█" : " " }.join }.join("\n")
