heights = ARGF.read.lines(chomp: true).map(&:chars)
  .each.with_index.with_object({}) do |(row,y),map|
    row.each.with_index do |height,x|
      map[[y,x]] = height
    end
  end

class HeightMap
  def initialize(heights)
    @heights = heights
  end

  def shortest(from:, to:)
    queue = [from]
    visited = { from => 0 }

    until queue.empty? || visited.has_key?(to)
      current = queue.shift
      moves = visited.fetch(current)

      neighbors = [
        [-1,  0],
        [ 1,  0],
        [ 0, -1],
        [ 0,  1],
      ].map { current.zip(_1).map {|a,b| a + b } }
        .select { @heights.has_key?(_1) }
        .reject { visited.has_key?(_1) }
        .select { @heights.fetch(_1).ord - 1 <= @heights.fetch(current).ord }

      neighbors.each do |y,x|
        visited[[y,x]] = moves + 1
        queue << [y,x]
      end

      queue.sort_by { visited.fetch(_1) }
    end

    visited.fetch(to, nil)
  end
end

s, e = heights.invert.values_at(?S, ?E)
heights[s] = ?a
heights[e] = ?z

hm = HeightMap.new(heights)
p hm.shortest(from: s, to: e)

p heights.select { _2 == ?a }.map(&:first).map { hm.shortest(from: _1, to: e) }.compact.min
