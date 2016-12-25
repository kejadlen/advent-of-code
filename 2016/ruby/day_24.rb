class Solver
  def initialize(maze)
    @maze = maze
  end

  def solve(from, to)
    seen = Set.new(from)
    queue = [[from, 0]]
    current = queue.shift

    loop do
      location = current[0]
      break if location == to
      if seen.include?(location)
        current = queue.shift
        next
      end

      seen << location

      neighbors = maze
        .open_neighbors(location[0], location[1])
        .reject {|location| seen.include?(location) }

      queue.concat(neighbors.map {|location| [location, current[1] + 1] })

      return nil if queue.empty?
      current = queue.shift
    end

    current[1]
  end

  private

  attr_reader :maze
end

class Maze
  attr_reader :locations

  def initialize(input)
    @maze = Hash.new
    @locations = Hash.new

    x, y = 0, 0
    input.chars.each do |char|
      case char
      when /\d/
        @locations[char.to_i] = [x,y]
        char = ?.
      when "\n"
        x = -1
        y += 1
      else
        # no-op
      end

      @maze[[x,y]] = char
      x += 1
    end
  end

  def [](x,y)
    maze[[x,y]]
  end

  def open_neighbors(x, y)
    [[-1,  0],
     [ 1,  0],
     [ 0, -1],
     [ 0,  1]].map {|dx,dy|
       [x+dx, y+dy]
     }.select {|x,y|
       self[x,y] == ?.
     }
  end

  private

  attr_reader :maze
end

if __FILE__ == $0
  maze = Maze.new(ARGF.read)
  solver = Solver.new(maze)

  hash = maze.locations.to_a.combination(2).each.with_object({}) {|(a, b), hash|
    steps = solver.solve(a[1], b[1])
    hash[[a[0],b[0]]] = steps
    hash[[b[0],a[0]]] = steps
  }

  p maze
    .locations
    .map(&:first)
    .permutation
    .select {|route| route[0] == 0 }
    .map {|route| route + [0] }
    .map {|route|
      [route, route.each_cons(2).map {|a,b| hash[[a,b]] }.inject(:+)]
    }.sort_by(&:last)
    .first
end

require 'minitest'
# require 'minitest/autorun'

class TestMaze < Minitest::Test
  def test_maze
    maze = Maze.new(<<-MAZE)
###########
#0.1.....2#
#.#######.#
#4.......3#
###########
MAZE
    assert_equal [1,1], maze.locations[0]

    assert_equal [[2,1], [1,2]], maze.open_neighbors(1,1)
  end
end

class TestSolver < Minitest::Test
  def test_solver
    maze = Maze.new(<<-MAZE)
###########
#0.1.....2#
#.#######.#
#4.......3#
###########
MAZE
    solver = Solver.new(maze)
    assert_equal 2, solver.solve(maze.locations[0], maze.locations[4])
  end
end
