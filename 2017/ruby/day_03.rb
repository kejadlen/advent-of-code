input = ARGF.read.to_i

dir = [1,0]

def next_dir(dir)
  case dir
  when [1,0]
    [0,1]
  when [0,1]
    [-1,0]
  when [-1,0]
    [0,-1]
  when [0,-1]
    [1,0]
  else
    raise "invalid dir: #{dir}"
  end
end

grid = Hash.new(0)
grid[[0,0]] = 1

def next_value(grid, x, y)
  [[-1, 1],[0, 1],[1,1],
   [-1, 0],       [1,0],
   [-1,-1],[0,-1],[1,-1]].map {|i,j| grid[[x+i,y+j]]}.sum
end

current = [0,0]
loop do
  next_square = current.zip(dir).map {|a,b| a + b }
  value = next_value(grid, *next_square)
  puts "#{current}: #{value}"
  exit if value > input
  grid[next_square] = value
  current = next_square
  dir = next_dir(dir) if grid[current.zip(next_dir(dir)).map {|a,b| a + b }] == 0
end

p next_value(grid, 1,0)
