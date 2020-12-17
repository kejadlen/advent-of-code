DIMENSIONS = 4
state = ARGF.read.strip.split("\n").flat_map.with_index {|line,y|
  line.chars.map.with_index {|c,x|
    [[x,y].fill(0, 2, DIMENSIONS-2), c == "#"]
  }
}.to_h

NEIGHBORS = (0...3**DIMENSIONS)
  .reject {|n| n == 3**DIMENSIONS / 2 }
  .map {|n| n.digits(3) }
  .map {|n| (0...DIMENSIONS).map {|x| n.fetch(x, 0) - 1 }}

def tick(state)
  actives = state.select {|_,c| c }.keys
  minmaxes = actives
    .transpose.map(&:minmax)
    .map {|min,max| (min-1..max+1).to_a }
  coords = minmaxes.inject {|n,x|
    n.flat_map {|nn| x.map {|xx| [nn, xx] }}
  }.map(&:flatten)
  coords.map {|coord|
    active_neighbors = NEIGHBORS.count {|delta| state[coord.zip(delta).map {|a,b| a + b }] }
    [ coord,
      state[coord] ? (2..3).cover?(active_neighbors) : active_neighbors == 3
    ]
  }.to_h
end

6.times do
  state = tick(state)
end

p state.values.count(&:itself)
