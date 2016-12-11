require 'delegate'

class State
  attr_reader :floors, :elevator

  def initialize(input)
    @floors = input.lines.reverse.map.with_index {|line, index|
      _, e, *items = line.split(/\s+/)
      @elevator = index if e == ?E
      Floor.new(items.reject {|item| item == ?. })
    }
  end
end

class Floor < SimpleDelegator
  attr_reader :source

  def initialize(items)
    @source = super(items)
  end

  def microchips
    source.select {|item| item.end_with?(?M) }.map {|item| item.chomp(?M) }
  end

  def generators
    source.select {|item| item.end_with?(?G) }.map {|item| item.chomp(?G) }
  end
end

require 'minitest/autorun'

class TestDay11 < Minitest::Test
  INPUT = <<-INPUT
F4 .  .  .  .  .
F3 .  .  .  LG .
F2 .  HG .  .  .
F1 E  .  HM .  LM
  INPUT

  def setup
    @state = State.new(INPUT)
  end

  def test_initialize
    assert_equal 4, @state.floors.size
    assert_equal 0, @state.elevator

    floor = @state.floors[0]
    assert_equal 2, floor.size
    assert_equal %w[ H L ], floor.microchips
    assert_empty floor.generators
  end
end
