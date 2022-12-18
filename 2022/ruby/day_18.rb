cubes = ARGF.read.lines(chomp: true).map { _1.split(?,).map(&:to_i) }

# part one
# p cubes.sum {|cube|
#   6 - cubes.count {|other|
#     cube.zip(other).map { _1 - _2 }.map(&:abs).sum == 1
#   }
# }

deltas = [
  [-1,  0,  0],
  [ 1,  0,  0],
  [ 0, -1,  0],
  [ 0,  1,  0],
  [ 0,  0, -1],
  [ 0,  0,  1],
]

bounds = cubes.transpose.map(&:minmax).map {|(min, max)| (min-1..max+1) }
cubes = cubes.to_h { [_1, true] }
corners = [
  [bounds[0].begin, bounds[1].begin, bounds[2].begin],
  [bounds[0].begin, bounds[1].begin, bounds[2].end],
  [bounds[0].begin, bounds[1].end, bounds[2].begin],
  [bounds[0].begin, bounds[1].end, bounds[2].end],
  [bounds[0].end, bounds[1].begin, bounds[2].begin],
  [bounds[0].end, bounds[1].begin, bounds[2].end],
  [bounds[0].end, bounds[1].end, bounds[2].begin],
  [bounds[0].end, bounds[1].end, bounds[2].end],
]

frontier = [corners[0]]
seen = Hash.new

until frontier.empty?
  current = frontier.shift

  neighbors = deltas.map {|delta| current.zip(delta).map { _1 + _2 }}
    .select {|neighbor| bounds.zip(neighbor).all? {|(bound, i)| bound.cover?(i) }}

  seen[current] = neighbors.any? { cubes.has_key?(_1) }

  frontier.concat(neighbors.reject {|neighbor| seen.has_key?(neighbor) || cubes.has_key?(neighbor) })
  frontier.uniq!
end

p cubes.keys.sum {|cube|
  neighbors = deltas.map {|delta| cube.zip(delta).map { _1 + _2 }}
  neighbors.count { seen.has_key?(_1) }
}
