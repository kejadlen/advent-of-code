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
  changes = area.changes

  # Part One
  # 11.times do |i|
  1000000001.times do |i|
    changes.next

    wooded = area.acres.flat_map(&:itself).count(?|)
    lumberyards = area.acres.flat_map(&:itself).count(?#)

    puts "#{i}: #{wooded * lumberyards}"
  end

  wooded = area.acres.flat_map(&:itself).count(?|)
  lumberyards = area.acres.flat_map(&:itself).count(?#)
  wooded * lumberyards
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]

  puts solve(ARGF.read)
end

__END__
Here's the cycle, 28 minutes long:

1000000000 % 28 = 552 % 28
552 % 28 = 20

540: 223468
541: 227744
542: 226338
543: 221697
544: 214775
545: 206150
546: 200326
547: 197380
548: 177364
549: 177834
550: 176960
551: 176490
552: 174584
553: 177683
554: 176808
555: 176715
556: 177784
557: 182016
558: 182479
559: 188256
560: 194892
561: 199864
562: 206720
563: 210330
564: 212102
565: 212310
566: 215306
567: 217260
