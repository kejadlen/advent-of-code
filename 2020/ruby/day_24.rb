require "set"
require "strscan"

def parse(line)
  deltas = []

  ss = StringScanner.new(line)
  until ss.eos?
    deltas << case
              when ss.scan(/e/)  then [ 1,  0]
              when ss.scan(/se/) then [ 0,  1]
              when ss.scan(/sw/) then [-1,  1]
              when ss.scan(/w/)  then [-1,  0]
              when ss.scan(/nw/) then [ 0, -1]
              when ss.scan(/ne/) then [ 1, -1]
              else fail
              end
  end

  deltas.inject {|c,d| c.zip(d).map {|c,d| c+d }}
end

NEIGHBORS = %w[ e se sw w nw ne ].map {|dir| parse(dir) }
def tick(tiles)
  coords = Set.new(tiles.flat_map {|coord|
    [
      coord,
      *NEIGHBORS.map {|n| coord.zip(n).map {|c,d| c+d }},
    ]
  })
  Set.new(coords.select {|coord|
    live_neighbors = NEIGHBORS.map {|n| coord.zip(n).map {|c,d| c+d }}.count {|c| tiles.include?(c) }
    if tiles.include?(coord)
      (1..2).cover?(live_neighbors)
    else
      live_neighbors == 2
    end
  })
end

tiles = Set.new
ARGF.read.split("\n").each do |line|
  tile = parse(line)
  if tiles.include?(tile)
    tiles.delete(tile)
  else
    tiles << tile
  end
end

100.times do |i|
  tiles = tick(tiles)
end

p tiles.size
