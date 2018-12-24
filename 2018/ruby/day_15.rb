require "minitest"

class Combat
end

class Grid
  def self.parse(s)
    occupied = {}
    s.chomp.lines.each.with_index do |row, y|
      row.chomp.chars.each.with_index do |pos, x|
        case pos
        when ?#
          occupied[[y, x]] = :wall
        when ?E
          occupied[[y, x]] = Elf.new
        when ?G
          occupied[[y, x]] = Goblin.new
        when ?.
        else
          fail "Invalid character: #{pos.inspect}"
        end
      end
    end
    self.new(occupied)
  end

  def initialize(occupied)
    @occupied = occupied
  end

  def [](pos)
    y, x = pos
    @occupied[[y, x]]
  end

  def to_s
    max_y = @occupied.keys.map(&:first).max
    max_x = @occupied.keys.map(&:last).max
    (0..max_y).map {|y|
      (0..max_x).map {|x|
        case @occupied[[y, x]]
        when :wall
          ?#
        when Elf
          ?E
        when Goblin
          ?G
        when nil
          ?.
        else
          fail "Unexpected object: #{@occupied[[y, x]]}"
        end
      }.join
    }.join(?\n)
  end
end

class TestGrid < Minitest::Test
  def test_parse
    grid = Grid.parse(<<~GRID)
      #######
      #E..G.#
      #...#.#
      #.G.#G#
      #######
    GRID

    assert_equal :wall, grid[[0,0]]
    assert_equal :wall, grid[[2,4]]
    assert_equal :wall, grid[[4,6]]

    assert_instance_of Elf, grid[[1,1]]
    assert_instance_of Goblin, grid[[1,4]]
    assert_instance_of Goblin, grid[[3,5]]

    assert_nil grid[[1,2]]
    assert_nil grid[[2,5]]
  end
end

class Unit
end

class Elf < Unit
end

class Goblin < Unit
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]


end
