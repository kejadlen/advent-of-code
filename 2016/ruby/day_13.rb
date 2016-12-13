class Maze
  attr_reader :walls

  def initialize(seed)
    @walls = Hash.new {|h,k|
      x,y = k
      num = x*x + 3*x + 2*x*y + y + y*y + seed
      h[k] = num.to_s(2).chars.count {|c| c == ?1 }.odd?
    }
  end

  def [](x,y)
    walls[[x, y]]
  end
end

require 'minitest/autorun'

class TestMaze < Minitest::Test
  def test_maze
    maze = Maze.new(10)
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
        assert_equal c, maze[x,y] ??#:?.
      end
    end
  end
end
