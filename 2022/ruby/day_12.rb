class HeightMap
  NEIGHBORS = [[0, -1], [-1, 0], [0, 1], [1, 0]]

  def initialize(heights)
    @heights = heights
  end

  def shortest(from:, to:, &cond)
    frontier = [from]
    visited = { from => 0 }

    until frontier.empty? || to.any? { visited.has_key?(_1) }
      current = frontier.shift

      NEIGHBORS.each do |delta|
        candidate = current.zip(delta).map { _1 + _2 }

        next if visited.has_key?(candidate)
        next unless cand_height = @heights[candidate]
        next unless cond.(@heights.fetch(current), cand_height)

        visited[candidate] = visited.fetch(current) + 1
        frontier << candidate
      end

      frontier.sort_by { visited.fetch(_1) }
    end

    visited.find {|k,v| to.include?(k) }.last
  end
end

heights = ARGF.read.lines(chomp: true).map(&:chars)
  .flat_map.with_index {|row,y|
    row.map.with_index {|height,x| [[y, x], height] }
  }.to_h

s, e = heights.invert.values_at(?S, ?E)
heights[s] = ?a
heights[e] = ?z

hm = HeightMap.new(heights)

# part one
p hm.shortest(from: s, to: [e]) { _1.ord + 1 >= _2.ord }

# part two
as = heights.select { _2 == ?a }.map(&:first)
p hm.shortest(from: e, to: as) { _1.ord - 1 <= _2.ord }
