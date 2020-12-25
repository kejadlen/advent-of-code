require "strscan"

def parse(line)
  deltas = []

  ss = StringScanner.new(line)
  until ss.eos?
    deltas << case
              when ss.scan(/e/)  then [ 1, -1,  0]
              when ss.scan(/se/) then [ 0, -1,  1]
              when ss.scan(/sw/) then [-1,  0,  1]
              when ss.scan(/w/)  then [-1,  1,  0]
              when ss.scan(/nw/) then [ 0,  1, -1]
              when ss.scan(/ne/) then [ 1,  0, -1]
              else fail
              end
  end

  deltas.inject {|(x,y,z),(dx,dy,dz)| [x+dx, y+dy, z+dz] }
end

tiles = Hash.new(false)
ARGF.read.split("\n").map {|line| parse(line) }
  .each do |tile|
    tiles[tile] = !tiles[tile]
  end

NEIGHBORS = %w[ e se sw w nw ne ].map {|dir| parse(dir) }
def tick(tiles)
  candidates = tiles.keys.flat_map {|coord|
    [
      coord,
      *NEIGHBORS.map {|n| coord.zip(n).map {|c,d| c + d }},
    ]
  }
  candidates.map {|coord|
    live_neighbors = NEIGHBORS.map {|n| coord.zip(n).map {|c,d| c + d }}.count {|c| tiles[c] }
    if tiles[coord]
      [coord, (1..2).cover?(live_neighbors)]
    else
      [coord, live_neighbors == 2]
    end
  }.to_h.select {|_,v| v }
end

100.times do
  tiles = tick(tiles)
end

p tiles.values.count(true)
