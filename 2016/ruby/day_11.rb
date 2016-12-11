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
    eql?(state)
  end

  def eql?(state)
    elevator == state.elevator && floors.zip(state.floors).all? {|a,b| a.eql?(b) }
  end

  def candidates
    [-1, 1].flat_map {|delta|
      next_floor = elevator + delta
      next [] unless (0...floors.size).cover?(next_floor)

      elevator_items = [1, 2].flat_map {|n| current_floor.to_a.combination(n).to_a }
      elevator_items.map {|items| move(items, elevator, next_floor) }
    }
  end

  def irradiated?
    floors.any?(&:irradiated?)
  end

  def to_s
    floors.map.with_index {|floor, index|
      "#{elevator == index ??E:?.} #{floor.inspect}"
    }.reverse.join("\n")
  end

  private

  def current_floor
    floors[elevator]
  end

  def move(items, from, to)
    from_floor = Floor.new(floors[from] - items)
    to_floor = Floor.new(floors[to] + items)

    floors = self.floors.clone
    floors[from] = from_floor
    floors[to] = to_floor

    self.class.new(floors, to)
  end
end

class Floor < SimpleDelegator
  attr_reader :source

  def initialize(items)
    @source = super(Set.new(items))
  end

  def microchips
    source.select {|item| item.end_with?(?M) }.map {|item| item.chomp(?M) }
  end

  def generators
    source.select {|item| item.end_with?(?G) }.map {|item| item.chomp(?G) }
  end

  def shielded
    microchips & generators
  end

  def irradiated?
    !(generators.empty? || (microchips - generators).empty?)
  end

  def hash
    id.hash
  end

  def eql?(floor)
    id == floor.id
  end

  def id
    [shielded.size, (microchips - shielded).size, (generators - shielded).size]
  end
end

if __FILE__ == $0
  INPUT = <<-INPUT
F4 .
F3 .  CoM CuM RM PlM
F2 .  CoG CuG RG PlG
F1 E  PrG PrM EG EM DG DM
  INPUT

  Step = Struct.new(:state, :count)
  seen = Set.new
  steps = [Step.new(State.from_s(INPUT), 0)]

  until steps.empty? do
    step = steps.shift

    # puts
    # puts "Steps: #{step.count}"
    # puts step.state

    if step.state.floors[0..-2].all?(&:empty?)
      puts
      puts "Steps: #{step.count}"
      puts step.state
      exit
    end

    step.state.candidates.each do |candidate|
      next if seen.include?(candidate)

      seen << candidate
      next if candidate.irradiated?

      steps << Step.new(candidate, step.count + 1)
    end
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
    state = State.from_s(<<-INPUT)
F4 .  .  .  .  .
F3 .  .  .  HG .
F2 .  LG .  .  .
F1 E  .  HM .  LM
  INPUT
    assert_equal @state, state
    assert_equal @state.hash, state.hash
    assert @state.eql?(state)

    set = Set.new
    set << @state
    assert_includes set, @state
    assert_includes set, state
  end

  def test_candidates
    candidates = @state.candidates
    assert_equal 3, candidates.size

    candidate = candidates[0]
    assert_equal 1, candidate.elevator
    assert_equal %W[ LM ], candidate.floors[0].to_a
    assert_equal %W[ HG HM ], candidate.floors[1].to_a

    candidate = candidates[1]
    assert_equal 1, candidate.elevator
    assert_equal %W[ HM ], candidate.floors[0].to_a
    assert_equal %W[ HG LM ], candidate.floors[1].to_a

    candidate = candidates[2]
    assert_equal 1, candidate.elevator
    assert_empty candidate.floors[0]
    assert_equal %W[ HG HM LM ], candidate.floors[1].to_a
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
