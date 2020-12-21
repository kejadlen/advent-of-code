class Tile
  SIZE = 10

  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def edges
    {
      top: @raw.fetch(0),
      bottom: @raw.fetch(SIZE-1),
      left: @raw.transpose.fetch(0),
      right: @raw.transpose.fetch(SIZE-1),
    }
  end

  def to_s
    @raw.map(&:join).join("\n")
  end
end

input = ARGF.read
  .scan(/Tile (\d+):\n((?:[.#]+\n)+)/m)
  .to_h
  .transform_keys(&:to_i)
  .transform_values {|v| v.split("\n").map {|row| row.chars } }
  .transform_values {|v| Tile.new(v) }

edges = input.flat_map {|id,tile|
  tile.edges.map {|edge,data| ["#{id}_#{edge}", data.join] }
}.to_h

inverted_edges = edges.each.with_object(Hash.new {|h,k| h[k] = [] }) do |(id,data),hash|
  hash[data] << id
end

matches = edges.map {|id,data|
  [
    id,
    [
      inverted_edges[data],
      inverted_edges[data.reverse],
    ].flatten.compact.reject {|other| other == id },
  ]
}.to_h

corners = input.keys.select {|id|
  %w[ top bottom left right ].count {|edge|
    matches.fetch("#{id}_#{edge}").empty?
  } == 2
}

p corners.inject(&:*)
