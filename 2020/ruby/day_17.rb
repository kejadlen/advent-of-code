state = ARGF.read.split("\n").flat_map.with_index {|line,y|
  line.chars.map.with_index {|c,x| [[0,0,y,x], c == "#"] }
}.to_h

NEIGHBORS = (0...3**4).map {|n| n.digits(3) }.map {|n| (0..3).map {|x| n.fetch(x, 0) - 1 }} - [[0,0,0,0]]

def tick(state)
  actives = state.select {|_,c| c }.keys
  ww, zz, yy, xx = actives.transpose.map(&:minmax).map {|min,max| [min-1, max+1] }
  Range.new(*ww).flat_map {|w|
    Range.new(*zz).flat_map {|z|
      Range.new(*yy).flat_map {|y|
        Range.new(*xx).map {|x|
          active_neighbors = NEIGHBORS.map {|dw,dz,dy,dx| state[[w+dw,z+dz,y+dy, x+dx]] }.count(&:itself)
          wzyx = [w,z,y,x]
          [ wzyx,
            state[wzyx] ? (2..3).cover?(active_neighbors) : active_neighbors == 3
          ]
        }
      }
    }
  }.to_h
end

6.times do
  state = tick(state)
end

p state.values.count(&:itself)
