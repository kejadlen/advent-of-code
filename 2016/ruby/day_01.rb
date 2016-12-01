include Math

Instruction = Struct.new(:direction, :blocks) do
  def initialize(direction, blocks)
    super(direction, blocks.to_i)
  end
end

Turtle = Struct.new(:orientation, :location) do
  def self.run(input)
    instructions = parse(input)
    turtles = [Turtle.new(-PI/2, [0,0])]

    instructions.each.with_object(turtles) do |instruction, turtles|
      turtles << turtles.last.turn(instruction.direction).step
      (instruction.blocks - 1).times do
        turtles << turtles.last.step
      end
    end

    turtles
  end

  def self.parse(input)
    input.split(', ').map {|step|
      Instruction.new(*step.scan(/(?<turn>\w)(?<blocks>\d+)/)[0])
    }
  end

  def turn(direction)
    angle = case direction
            when ?R
              PI/2
            when ?L
              -PI/2
            else
              raise "unexpected direction: #{direction}"
            end
    Turtle.new(orientation + angle, location)
  end

  def step
    x = location[0] + cos(orientation).to_i
    y = location[1] + sin(orientation).to_i
    Turtle.new(orientation, [x, y])
  end
end

require 'minitest'
# require 'minitest/autorun'
class TestInstructions < Minitest::Test
  def test_instructions
    assert_distance 5, 'R2, L3'
    assert_distance 2, 'R2, R2, R2'
    assert_distance 12, 'R5, L5, R5, R3'
  end

  def assert_distance(expected, instructions)
    assert_equal expected, Turtle.run(instructions).last.location.map(&:abs).inject(:+)
  end
end

if __FILE__ == $0
  turtles = Turtle.run(DATA.read)
  p turtles.last

  locations = turtles.map(&:location)
  p locations.find {|location| locations.count(location) > 1 }
end

__END__
R4, R3, L3, L2, L1, R1, L1, R2, R3, L5, L5, R4, L4, R2, R4, L3, R3, L3, R3, R4, R2, L1, R2, L3, L2, L1, R3, R5, L1, L4, R2, L4, R3, R1, R2, L5, R2, L189, R5, L5, R52, R3, L1, R4, R5, R1, R4, L1, L3, R2, L2, L3, R4, R3, L2, L5, R4, R5, L2, R2, L1, L3, R3, L4, R4, R5, L1, L1, R3, L5, L2, R76, R2, R2, L1, L3, R189, L3, L4, L1, L3, R5, R4, L1, R1, L1, L1, R2, L4, R2, L5, L5, L5, R2, L4, L5, R4, R4, R5, L5, R3, L1, L3, L1, L1, L3, L4, R5, L3, R5, R3, R3, L5, L5, R3, R4, L3, R3, R1, R3, R2, R2, L1, R1, L3, L3, L3, L1, R2, L1, R4, R4, L1, L1, R3, R3, R4, R1, L5, L2, R2, R3, R2, L3, R4, L5, R1, R4, R5, R4, L4, R1, L3, R1, R3, L2, L3, R1, L2, R3, L3, L1, L3, R4, L4, L5, R3, R5, R4, R1, L2, R3, R5, L5, L4, L1, L1
