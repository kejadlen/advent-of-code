map = ARGF.read.split("\n").map(&:chars)
rows = map.size
cols = map[0].size
slopes = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2],
]
puts slopes.map {|dx,dy|
  Array.new(rows / dy) {|i| [dx*i % cols, dy*i] }
    .map {|x,y| map[y][x] }
    .count(?#)
}.reduce(&:*)
