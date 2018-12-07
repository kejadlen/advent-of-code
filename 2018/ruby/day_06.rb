require "set"

coords = ARGF.read.chomp.lines.map(&:chomp).map {|line| line.split(", ").map(&:to_i) }

x_min = coords.map(&:first).min
x_max = coords.map(&:first).max
y_min = coords.map(&:last).min
y_max = coords.map(&:last).max

coords = coords.map.with_index {|c,i| [i, c] }

p coords

p x_min, x_max, y_min, y_max

def manhattan_distance(a, b)
  (a[0] - b[0]).abs + (a[1] - b[1]).abs
end

grid = {}
(x_min..x_max).each do |x|
  (y_min..y_max).each do |y|
    # Part One
    # distances = coords.map {|id, coord|
    #   [id, manhattan_distance(coord, [x,y])]
    # }
    # min_distance = distances.map(&:last).min
    # closests = distances.select {|_,distance| distance == min_distance }
    # grid[[x,y]] = closests.length > 1 ? nil : closests.first.first

    # Part Two
    total_distance = coords.map {|_,coord| manhattan_distance(coord, [x,y]) }.sum
    grid[[x,y]] = true if total_distance < 10000
  end
end

# Part One
# infinites = Set.new
# (x_min..x_max).each do |x|
#   infinites << grid[[x,y_min]]
#   infinites << grid[[x,y_max]]
# end
# (y_min..y_max).each do |y|
#   infinites << grid[[x_min,y]]
#   infinites << grid[[x_max,y]]
# end
# p grid.values.group_by(&:itself).transform_values(&:count).reject {|k,_| infinites.include?(k) }.max_by(&:last)

p grid.size
