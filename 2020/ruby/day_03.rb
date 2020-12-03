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
  map.each_slice(dy).map(&:first)
    .map.with_index {|row,i| row[dx*i % cols] }
    .count(?#)
}.reduce(&:*)
