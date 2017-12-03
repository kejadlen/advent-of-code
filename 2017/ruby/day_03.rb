require "minitest"

class Spiral
  def initialize
    @square = [0,0]
    @dir = [1,0]
    @steps = [1, 1]
  end

  def each
    return enum_for(__method__) unless block_given?

    loop do
      yield @square
      step!
    end
  end

  private

  def step!
    @steps[0] -= 1
    @square = @square.zip(@dir).map {|i,j| i+j }
    if @steps[0] == 0
      change_dir!
      @steps << next_steps
      @steps.shift
    end
  end

  def change_dir!
    @dir = case @dir
           when [1,0]
             [0,1]
           when [0,1]
             [-1,0]
           when [-1,0]
             [0,-1]
           when [0,-1]
             [1,0]
           else
             raise "invalid dir: #@dir"
    end
  end

  def next_steps
    case @dir
    when [1,0]
      @steps[1]
    when [0,1]
      @steps[1] + 1
    when [-1,0]
      @steps[1]
    when [0,-1]
      @steps[1] + 1
    else
      raise "invalid dir: #@dir"
    end
  end
end

if $0 == __FILE__
  if ARGV.shift == "test"
    require "minitest/test"
  else
    input = ARGF.read.to_i
    p Spiral.new.each.with_index.find {|_,i| i == input - 1 }.first.sum
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
