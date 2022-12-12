height_map = ARGF.read.lines(chomp: true).map(&:chars)
  .each.with_index.with_object({}) do |(row,y),map|
    row.each.with_index do |height,x|
      map[[y,x]] = height
    end
  end

s, e = height_map.invert.values_at(?S, ?E)
height_map[s] = ?a
height_map[e] = ?z

# part one
# queue = [s]
# visited = { s => 0 }

# until visited.has_key?(e)
#   current = queue.shift
#   moves = visited.fetch(current)

#   neighbors = [
#     [-1,  0],
#     [ 1,  0],
#     [ 0, -1],
#     [ 0,  1],
#   ].map { current.zip(_1).map {|a,b| a + b } }
#     .select { height_map.has_key?(_1) }
#     .reject { visited.has_key?(_1) }
#     .select { height_map.fetch(_1).ord - 1 <= height_map.fetch(current).ord }

#   neighbors.each do |y,x|
#     visited[[y,x]] = moves + 1
#     queue << [y,x]
#   end

#   queue.sort_by { visited.fetch(_1) }
# end

# p visited.fetch(e)

# part two
queue = [e]
visited = { e => 0 }

loop do
  current = queue.shift
  moves = visited.fetch(current)

  neighbors = [
    [-1,  0],
    [ 1,  0],
    [ 0, -1],
    [ 0,  1],
  ].map { current.zip(_1).map {|a,b| a + b } }
    .select { height_map.has_key?(_1) }
    .reject { visited.has_key?(_1) }
    .select { height_map.fetch(current).ord <= height_map.fetch(_1).ord + 1 }

  if a = neighbors.find { height_map.fetch(_1) == ?a }
    p moves + 1
    break
  end

  neighbors.each do |y,x|
    visited[[y,x]] = moves + 1
    queue << [y,x]
  end

  queue.sort_by { visited.fetch(_1) }
end
