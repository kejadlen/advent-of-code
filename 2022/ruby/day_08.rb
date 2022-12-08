# grid = ARGF.read.lines(chomp: true).map {|row| row.chars.map { [_1.to_i, false] }}

# def mark!(ary)
#   max = -1
#   ary.each do |tree_counted|
#     if tree_counted.first > max
#       max = tree_counted.first
#       tree_counted[1] = true
#     end
#   end
# end

# grid.each { mark!(_1) }
# grid.each { mark!(_1.reverse) }
# grid.transpose.each { mark!(_1) }
# grid.transpose.each { mark!(_1.reverse) }

# p grid.sum { _1.count(&:last) }

grid = ARGF.read.lines(chomp: true).map { _1.chars.map(&:to_i) }

def score(grid, y, x)
  tree = grid[y][x]

  [
    (0...y).to_a.reverse.slice_after {|i| grid[i][x] >= tree }.first,
    (y+1...grid.size).slice_after {|i| grid[i][x] >= tree }.first,
    (0...x).to_a.reverse.slice_after {|i| grid[y][i] >= tree }.first,
    (x+1...grid.size).slice_after {|i| grid[y][i] >= tree }.first,
  ].compact.map(&:size).inject(:*)
end

p grid.flat_map.with_index {|row,y|
  row.map.with_index {|tree,x|
    score(grid, y, x)
  }
}.max
