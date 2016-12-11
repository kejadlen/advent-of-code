class State
  attr_reader :floors, :elevator

  def initialize(input)
    @floors = input.lines.reverse.map.with_index {|line, index|
      _, e, *items = line.split(/\s+/)
      @elevator = index if e == ?E
      items.reject {|item| item == ?. }
    }
  end
end

require 'minitest/autorun'

class TestDay11 < Minitest::Test
  def test_initialize
    input = <<-INPUT
F4 .  .  .  .  .
F3 .  .  .  LG .
F2 .  HG .  .  .
F1 E  .  HM .  LM
    INPUT

    state = State.new(input)
    assert_equal 4, state.floors.size
    assert_equal 0, state.elevator

    floor = state.floors[0]
    assert_equal 2, floor.size
  end
end
