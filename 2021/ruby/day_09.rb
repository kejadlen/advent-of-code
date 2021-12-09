require "set"

INPUT = ARGF.read.split("\n").map {|l| l.chars.map(&:to_i) }

NEIGHBORS = [[0,-1], [-1, 0], [1, 0], [0, 1]]
def neighbors(y,x)
  NEIGHBORS
    .map {|dy,dx| [y+dy, x+dx] }
    .select {|y,x| (0...INPUT.size).cover?(y) && (0...INPUT[0].size).cover?(x) }
end

all = (0...INPUT.size).flat_map {|y| (0...INPUT[0].size).map {|x| [y, x]}}
lows = all.select {|y,x| neighbors(y,x).all? {|yy,xx| INPUT[yy][xx] > INPUT[y][x] }}
# p lows.sum {|y,x| INPUT[y][x] + 1 }

def fill_basin(low)
  basin = Set.new([low])

  stack = [low]
  until stack.empty?
    y,x = stack.shift
    new_neighbors = neighbors(y,x).reject {|y,x| basin.include?([y,x]) || INPUT[y][x] == 9 }
    stack.concat(new_neighbors)
    basin.merge(new_neighbors)
  end

  basin
end

p lows.map { fill_basin(_1) }.map(&:size).sort[-3, 3].inject(:*)

