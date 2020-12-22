# all rotations are clockwise
# all flips are vertical

class Tile
  attr_reader :id, :raw

  def initialize(id, raw)
    @id, @raw = id, raw
  end

  def [](y, x)
    @raw.fetch(y).fetch(x)
  end

  def edge_keys
    {
      top: @raw.first,
      down: @raw.last,
      left: @raw.transpose.first,
      right: @raw.transpose.last,
    }.transform_values(&:join)
  end

  def permutations
    (0..3).map {|i|
      i.times.inject(self) {|x,_| x.rotated }
    }.flat_map {|x| [x, x.flipped] }
  end

  def rotated
    self.class.new(@id, @raw.reverse.transpose)
  end

  def flipped
    self.class.new(@id, @raw.reverse)
  end

  def to_s
    @raw.map(&:join).join("\n")
  end
end

Edge = Struct.new(*%i[ key from to rotations is_mirrored ]) do
  def mirrored?
    is_mirrored
  end
end

tiles = ARGF.read
  .scan(/Tile (\d+):\n((?:[.#]+\n)+)/m)
  .to_h
  .transform_values {|v| v.split("\n").map {|row| row.chars } }
  .map {|k,v| [k, Tile.new(k, v)] }
  .to_h

keys_to_tiles = Hash.new {|h,k| h[k] = [] }
tiles.values.each do |tile|
  tile.edge_keys.values.each do |key|
    keys_to_tiles[key] << tile.id
    keys_to_tiles[key.reverse] << tile.id
  end
end

start_corner = tiles.values.find {|tile|
  tile.edge_keys.values_at(:left, :top).all? {|key| keys_to_tiles.fetch(key).size == 1 }
}

image = [[start_corner]]
until image.map(&:size).sum == tiles.size
  current = image.last.last
  right_key = current.edge_keys.fetch(:right)
  if right_id = keys_to_tiles.fetch(right_key, nil).find {|id| id != current.id }
    right_tile = tiles.fetch(right_id).permutations.find {|p| p.edge_keys.fetch(:left) == right_key }
    image.last << right_tile
  else
    current = image.last.first
    down_key = current.edge_keys.fetch(:down)
    break unless down_id = keys_to_tiles.fetch(down_key).find {|id| id != current.id }

    down_tile = tiles.fetch(down_id).permutations.find {|p| p.edge_keys.fetch(:top) == down_key }
    image << [down_tile]
  end
end

full_raw = image.map {|row| row.map {|tile|
  tile.raw[1..-2].map {|row| row[1..-2] }
}}.flat_map {|row| row.inject(&:zip).map(&:flatten) }
full_tile = Tile.new(nil, full_raw)

sea_monster = <<~SEA_MONSTER.split("\n").map(&:chars)
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   
SEA_MONSTER
needle = sea_monster.flat_map.with_index {|row,y|
  row.filter_map.with_index {|c,x|
    c == ?# ? [y,x] : nil
  }
}

num_monsters = full_tile.permutations.map {|tile|
  needle_maxes = needle.transpose.map(&:max)
  haystack = (0...tile.raw.size-needle_maxes.first).flat_map {|y|
    (0...tile.raw.first.size-needle_maxes.last).map {|x|
      [y, x]
    }
  }
  haystack.count {|y,x|
    needle.all? {|dy,dx| tile[y+dy, x+dx] == ?# }
  }
}.sum

puts full_tile.raw.map {|row| row.count(?#) }.sum - (num_monsters * needle.size)
