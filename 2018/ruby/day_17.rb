require "set"

require "minitest"
require "minitest/pride"

class Slice
  def self.parse(s)
    clay = Set.new
    s.scan(/^(x|y)=(\d+), (?:x|y)=(\d+)..(\d+)$/m).each do |xy, i, min, max|
      i, min, max = [i, min, max].map(&:to_i)
      clay.merge((min..max).map {|j| xy == ?x ? [j, i] : [i, j] })
    end
    new(clay)
  end

  def initialize(clay)
    @clay = clay
  end

  def to_s
    min_x, max_x = @clay.map(&:last).minmax
    min_y, max_y = @clay.map(&:first).minmax
    min_y = [0, min_y].min
    (min_y..max_y).map {|y|
      (min_x-1..max_x+1).map {|x|
        if [x, y] == [500, 0]
          ?+
        else
          @clay.include?([y, x]) ? ?# : ?.
        end
      }.join
    }.join(?\n)
  end
end

class TestSlice < Minitest::Test
  def test_parse_to_s
    slice = Slice.parse(<<~SLICE)
      x=495, y=2..7
      y=7, x=495..501
      x=501, y=3..7
      x=498, y=2..4
      x=506, y=1..2
      x=498, y=10..13
      x=504, y=10..13
      y=13, x=498..504
    SLICE

    assert_equal <<~SLICE.chomp, slice.to_s
      ......+.......
      ............#.
      .#..#.......#.
      .#..#..#......
      .#..#..#......
      .#.....#......
      .#.....#......
      .#######......
      ..............
      ..............
      ....#.....#...
      ....#.....#...
      ....#.....#...
      ....#######...
    SLICE
  end
end

def solve(input)
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]

  puts solve(ARGF.read)
end
