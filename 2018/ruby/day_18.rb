require "minitest"
require "minitest/pride"

class Area
  def self.parse(input)
    acres = input.chomp.lines.map {|row| row.chomp.chars.to_a }
    new(acres)
  end

  attr_reader :acres

  def initialize(acres)
    @acres = acres
  end

  def changes
    return enum_for(__method__) unless block_given?

    loop do
      yield self

      acres = @acres.map.with_index {|row, y|
        row.map.with_index {|acre, x|
          adjacent = self.adjacent(x, y)
          case self[x, y]
          when ?.
            (adjacent.count(?|) >= 3) ? ?| : ?.
          when ?|
            (adjacent.count(?#) >= 3) ? ?# : ?|
          when ?#
            (adjacent.count(?#) >= 1 && adjacent.count(?|) >= 1) ? ?# : ?.
          else
            fail "Unexpected acre: #{self[x, y]}"
          end
        }
      }
      @acres = acres
    end
  end

  def to_s
    @acres.map {|row| row.join }.join(?\n)
  end

  def [](x, y)
    @acres.fetch(y).fetch(x)
  end

  def adjacent(x, y)
    (-1..1).flat_map {|dx| (-1..1).map {|dy| [dx, dy] } }
      .reject {|dx,dy| dx == 0 && dy == 0 }
      .map {|dx, dy| [x+dx, y+dy] }
      .reject {|x, y| x < 0 || y < 0 }
      .map {|x, y|
        @acres.fetch(y) { [] }.fetch(x) { nil }
      }.compact
  end
end

class TestArea < Minitest::Test
  def test_area
    area = Area.parse(<<~AREA)
      .#.#...|#.
      .....#|##|
      .|..|...#.
      ..|#.....#
      #.#|||#|#|
      ...#.||...
      .|....|...
      ||...#|.#|
      |.||||..|.
      ...#.|..|.
    AREA
    changes = area.changes

    assert_equal <<~AREA.chomp, changes.next.to_s
      .#.#...|#.
      .....#|##|
      .|..|...#.
      ..|#.....#
      #.#|||#|#|
      ...#.||...
      .|....|...
      ||...#|.#|
      |.||||..|.
      ...#.|..|.
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      .......##.
      ......|###
      .|..|...#.
      ..|#||...#
      ..##||.|#|
      ...#||||..
      ||...|||..
      |||||.||.|
      ||||||||||
      ....||..|.
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      .......#..
      ......|#..
      .|.|||....
      ..##|||..#
      ..###|||#|
      ...#|||||.
      |||||||||.
      ||||||||||
      ||||||||||
      .|||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      .......#..
      ....|||#..
      .|.||||...
      ..###|||.#
      ...##|||#|
      .||##|||||
      ||||||||||
      ||||||||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      .....|.#..
      ...||||#..
      .|.#||||..
      ..###||||#
      ...###||#|
      |||##|||||
      ||||||||||
      ||||||||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      ....|||#..
      ...||||#..
      .|.##||||.
      ..####|||#
      .|.###||#|
      |||###||||
      ||||||||||
      ||||||||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      ...||||#..
      ...||||#..
      .|.###|||.
      ..#.##|||#
      |||#.##|#|
      |||###||||
      ||||#|||||
      ||||||||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      ...||||#..
      ..||#|##..
      .|.####||.
      ||#..##||#
      ||##.##|#|
      |||####|||
      |||###||||
      ||||||||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      ..||||##..
      ..|#####..
      |||#####|.
      ||#...##|#
      ||##..###|
      ||##.###||
      |||####|||
      ||||#|||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      ..||###...
      .||#####..
      ||##...##.
      ||#....###
      |##....##|
      ||##..###|
      ||######||
      |||###||||
      ||||||||||
      ||||||||||
    AREA

    assert_equal <<~AREA.chomp, changes.next.to_s
      .||##.....
      ||###.....
      ||##......
      |##.....##
      |##.....##
      |##....##|
      ||##.####|
      ||#####|||
      ||||#|||||
      ||||||||||
    AREA
  end
end

def solve(input)
  area = Area.parse(input)
  area = area.changes.lazy.drop(10).first
  wooded = area.acres.flat_map(&:itself).count(?|)
  lumberyards = area.acres.flat_map(&:itself).count(?#)
  wooded * lumberyards
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]

  puts solve(ARGF.read)
end
