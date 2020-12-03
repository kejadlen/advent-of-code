map = ARGF.read.split("\n").map(&:chars)
slopes = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2],
]
puts slopes.map {|dx,dy|
  x, y = 0, 0
  trees = 0
  until y >= map.length
    trees += 1 if map[y][x % map[0].size] == ?#
    x += dx
    y += dy
  end
  trees
}.reduce(&:*)
