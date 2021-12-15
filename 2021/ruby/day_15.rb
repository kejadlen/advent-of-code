require "set"

cavern = ARGF.read.split("\n").map { _1.chars.map(&:to_i) }
cavern = (0..4).flat_map {|i| cavern.map {|row|
  row.map { (_1 + i - 1) % 9 + 1 }
}}
cavern = cavern.map {|row| (0..4).flat_map {|i|
  row.map { (_1 + i - 1) % 9 + 1 }
}}

cavern = cavern
  .flat_map.with_index {|row,y| row.map.with_index {|risk,x| [[y,x], risk] }}
  .to_h
bottom_right = cavern.keys.max

risks = Hash.new(0)
risks[[0,0]] = 0
edges = Set[[0,0]]

until risks.has_key?(bottom_right)
  yx = edges.min_by { risks.fetch(_1) }
  edges.delete(yx)

  y,x = yx
  neighbors = [[-1, 0], [1, 0], [0, 1], [0, -1]]
    .map {|dy,dx| [y+dy, x+dx] }
    .select { cavern.has_key?(_1) }
    .reject { risks.has_key?(_1) }

  risk = risks.fetch(yx)
  neighbors.each do
    risks[_1] = risk + cavern.fetch(_1)
  end

  edges.merge(neighbors)
end

p risks[bottom_right]
