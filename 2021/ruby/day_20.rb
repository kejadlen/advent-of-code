algorithm, image = ARGF.read.strip.split("\n\n")

algorithm = algorithm.delete("\n") # for the example
algorithm = algorithm.chars.map.with_index { [_2, _1 == ?#] }.to_h

image = image.split("\n").flat_map.with_index {|row, y|
  row.chars.map.with_index {|pixel, x| [[y, x], pixel == ?#] }
}.to_h
image.default = false

def each(image)
  return enum_for(__method__, image) unless block_given?

  ys = image.keys.map(&:first).minmax
  xs = image.keys.map(&:last).minmax

  (ys[0]-1..ys[1]+1).each do |y|
    (xs[0]-1..xs[1]+1).each do |x|
      yield [y, x]
    end
  end
end

def debug(image)
  ys = image.keys.map(&:first).minmax
  xs = image.keys.map(&:last).minmax

  puts (ys[0]-1..ys[1]+1).map {|y|
    (xs[0]-1..xs[1]+1).map {|x|
      image[[y,x]] ? ?# : ?.
    }.join
  }.join("\n")
end

50.times {
  ys = image.keys.map(&:first).minmax
  xs = image.keys.map(&:last).minmax

  prev_default = image.default
  image = each(image).to_h {|y,x|
    area = (-1..1).flat_map {|dy| (-1..1).map {|dx| image[[y+dy, x+dx]] }}
    index = area.map { _1 ? 1 : 0 }.join.to_i(2)
    pixel = algorithm.fetch(index)
    [[y,x], pixel]
  }

  image.default = prev_default ? algorithm.fetch(511) : algorithm.fetch(0)
}

p image.count { _2 }
