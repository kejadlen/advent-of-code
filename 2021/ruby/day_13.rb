dots, folds = ARGF.read.split("\n\n")

dots = dots.scan(/(\d+),(\d+)/).map { _1.map(&:to_i) }
folds = folds.scan(/(x|y)=(\d+)/).map { [_1, _2.to_i] }

dirs = { ?x => 0, ?y => 1 }
folds.each do |dir, axis|
  index = dirs.fetch(dir)
  dots.select { _1[index] > axis }.each do |dot|
    dot[index] = axis - (dot[index] - axis)
  end
  dots.uniq!
  # p dots.size or exit
end

xx = Range.new(*dots.map(&:first).minmax)
yy = Range.new(*dots.map(&:last).minmax)
puts yy.map {|y| xx.map {|x| dots.include?([x,y]) ? "█" : " " }.join }.join("\n")
