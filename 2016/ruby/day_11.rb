require 'delegate'

State = Struct.new(:floors, :elevator) do
  def self.from_s(input)
    elevator = nil
    floors = input.lines.reverse.map.with_index {|line, index|
      _, e, *items = line.split(/\s+/)
      elevator = index if e == ?E
      Floor.new(items.reject {|item| item == ?. })
    }
    new(floors, elevator)
  end

  def ==(state)
    elevator == state.elevator && floors.zip(state.floors).all? {|a,b| a == b }
  end

  def candidates
    [-1, 1].flat_map {|delta|
      next_floor = elevator + delta
      next [] unless (0...floors.size).cover?(next_floor)

      current_floor.map {|item| move(item, elevator, next_floor) }
    }
  end

  def irradiated?
    floors.any?(&:irradiated?)
  end

  private

  def current_floor
    floors[elevator]
  end

  def move(item, from, to)
    from_floor = floors[from] - [item]
    to_floor = floors[to] + [item]

    floors = self.floors.clone
    floors[from] = from_floor
    floors[to] = to_floor

    self.class.new(floors, to)
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

  def irradiated?
    !(generators.empty? || (microchips - generators).empty?)
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
    @state = State.from_s(INPUT)
  end

  def test_initialize
    assert_equal 4, @state.floors.size
    assert_equal 0, @state.elevator

    floor = @state.floors[0]
    assert_equal 2, floor.size
    assert_equal %w[ H L ], floor.microchips
    assert_empty floor.generators
  end

  def test_equality
    state = State.from_s(INPUT)
    assert_equal @state, state
  end

  def test_candidates
    candidates = @state.candidates
    assert_equal 2, candidates.size

    candidate = candidates[0]
    assert_equal 1, candidate.elevator
    assert_equal %W[ LM ], candidate.floors[0]
    assert_equal %W[ HG HM ], candidate.floors[1]

    candidate = candidates[1]
    assert_equal 1, candidate.elevator
    assert_equal %W[ HM ], candidate.floors[0]
    assert_equal %W[ HG LM ], candidate.floors[1]
  end

  def test_irradiated
    refute Floor.new(%w[]).irradiated?
    refute Floor.new(%w[ BM ]).irradiated?
    refute Floor.new(%w[ BG ]).irradiated?
    refute Floor.new(%w[ BM BG ]).irradiated?
    refute Floor.new(%w[ BM BG LG ]).irradiated?

    assert Floor.new(%w[ BM LG ]).irradiated?
  end
end
