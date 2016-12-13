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

  def solve(from, to)
    seen = Set.new
    current = [[from, 0]]
    loop do
      pos, count = current.shift
      seen << pos
      x,y = pos

      [[1,0], [-1,0], [0,1], [0,-1]].map {|dx, dy|
        [x + dx, y + dy]
      }.reject {|x,y|
        x.negative? || y.negative?
      }.reject {|x,y|
        walls[[x,y]]
      }.reject {|x,y|
        seen.include?([x,y])
      }.each do |x,y|
        return count + 1 if to == [x,y]

        current << [[x,y], count + 1]
      end
    end
  end
end

if __FILE__ == $0
  maze = Maze.new(1358)
  puts maze.solve([1,1], [31,39])
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
