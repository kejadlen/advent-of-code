class Maze
  attr_reader :walls

  def initialize(seed)
    @walls = Hash.new {|h,(x,y)|
      num = x*x + 3*x + 2*x*y + y + y*y + seed
      h[[x,y]] = num.to_s(2).chars.count {|c| c == ?1 }.odd?
    }
  end

  def [](x,y)
    walls[[x, y]]
  end

  def solve(start)
    Solver.new(self, start)
  end

  class Solver
    attr_reader :maze, :seen, :current

    def initialize(maze, start)
      @maze = maze
      @seen = Set.new
      @current = [[start, 0]]
    end

    def walk
      return enum_for(__method__) unless block_given?

      loop do
        pos, count = current.shift
        seen << pos
        x,y = pos

        [[1,0], [-1,0], [0,1], [0,-1]].map {|dx, dy|
          [x + dx, y + dy]
        }.reject {|x,y|
          x.negative? || y.negative?
        }.reject {|x,y|
          maze[x,y]
        }.reject {|pos|
          seen.include?(pos)
        }.each do |pos|
          current << [pos, count + 1]
        end

        yield [pos, count]
      end
    end
  end
end

if __FILE__ == $0
  maze = Maze.new(1358)
  p maze.solve([1,1]).walk.take_while {|pos,count| count < 51 }.map(&:first).uniq.size
end

require 'minitest'
# require 'minitest/autorun'

class TestMaze < Minitest::Test
  def setup
    @maze = Maze.new(10)
  end

  def test_maze
    maze_s = <<-MAZE.chomp.split("\n").map(&:chars)
.#.####.##
..#..#...#
#....##...
###.#.###.
.##..#..#.
..##....#.
#...##.###
    MAZE
    maze_s.each.with_index do |row, y|
      row.each.with_index do |c, x|
        assert_equal c, @maze[x,y] ??#:?.
      end
    end
  end

  def test_solve
    assert_equal 11, @maze.solve([1,1], [7,4])
  end
end
