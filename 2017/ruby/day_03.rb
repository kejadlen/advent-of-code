require "minitest"

class Spiral
  def initialize
    @state = [0,0]
  end

  def each
    return enum_for(__method__) unless block_given?

    (1..Float::INFINITY).lazy
      .flat_map {|i| [i, i] }
      .zip(%i[r u l d].cycle)
      .flat_map {|n,d| Array.new(n, d) }
      .each do |dir|

      yield @state
      @state = @state.zip(
        case dir
        when :r
          [1, 0]
        when :u
          [0, 1]
        when :l
          [-1, 0]
        when :d
          [0, -1]
        end
      ).map {|a,b| a + b }

    end
  end

end

class Grid
  def initialize
    @grid = Hash.new {|h,(x,y)|
      neighbors = [[-1, 1], [0, 1], [1, 1],
                   [-1, 0],         [1, 0],
                   [-1,-1], [0,-1], [1,-1]]
      h[[x,y]] = neighbors
        .map {|i,j| [x+i,y+j] }
        .select {|i,j| h.has_key?([i,j]) }
        .map {|i,j| h[[i,j]] }
        .sum
    }
    @grid[[0,0]] = 1
  end

  def [](x,y)
    @grid[[x,y]]
  end
end

if $0 == __FILE__
  case ARGV.shift
  when "test"
    require "minitest/autorun"
  when "0"
    input = ARGF.read.to_i
    p Spiral.new.each.with_index.find {|_,i| i == input - 1 }.first.sum
  when "1"
    input = ARGF.read.to_i
    grid = Grid.new
    p Spiral.new.each.lazy.map {|x,y| grid[x,y] }.find {|value| value > input }
  end
end

class TestSpiral < Minitest::Test
  def test_spiral
    spiral = Spiral.new
    e = spiral.each
    assert_equal [0,0], e.next
    assert_equal [1,0], e.next
    assert_equal [1,1], e.next
    assert_equal [0,1], e.next
    assert_equal [-1,1], e.next
    assert_equal [-1,0], e.next
    assert_equal [-1,-1], e.next
    assert_equal [0,-1], e.next
    assert_equal [1,-1], e.next
    assert_equal [2,-1], e.next

    spiral = Spiral.new
    assert_equal [0,-2], spiral.each.with_index.find {|_,i| i == 22 }.first
  end
end

class TestGrid < Minitest::Test
  def test_grid
    grid = Grid.new
    assert_equal 1, grid[0,0]
    assert_equal 1, grid[1,0]
    assert_equal 2, grid[1,1]
    assert_equal 4, grid[0,1]
    assert_equal 5, grid[-1,1]
    assert_equal 10, grid[-1,0]
  end
end
