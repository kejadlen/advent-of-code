include Math

def follow_instructions(input)
  seq = input.split(', ')

  # start facing north at the origin
  dir = -PI/2
  locations = [[0,0]]
  seq.each.with_object(locations) do |step, locations|
    /(?<turn>\w)(?<blocks>\d+)/ =~ step

    case turn
    when ?R
      dir += PI/2
    when ?L
      dir -= PI/2
    else
      raise "unexpected turn: #{turn}"
    end

    blocks.to_i.times do
      location = locations.last
      x = location[0] + cos(dir).to_i
      y = location[1] + sin(dir).to_i
      locations << [x, y]
    end
  end

  locations
end

def first_dupe(ary)
  seen = Set.new
  ary.find { |elem|
    seen.include?(elem) || (seen << elem && false)
  }
end

require 'minitest'
# require 'minitest/autorun'
class TestInstructions < Minitest::Test
  def test_instructions
    assert_distance 5, 'R2, L3'
    assert_distance 2, 'R2, R2, R2'
    assert_distance 12, 'R5, L5, R5, R3'
  end

  def test_first_dupe
    assert_equal 1, first_dupe([1, 2, 3, 1])
    assert_equal 2, first_dupe([1, 2, 3, 2])
    assert_equal 3, first_dupe([1, 2, 3, 3])

    locations = follow_instructions('R8, R4, R4, R8')
    assert_equal [4, 0], first_dupe(locations)
  end

  def assert_distance(expected, instructions)
    locations = follow_instructions(instructions)
    assert_equal expected, locations.last.map(&:abs).inject(:+)
  end
end

if __FILE__ == $0
  puts first_dupe(follow_instructions(DATA.read))
end

__END__
R4, R3, L3, L2, L1, R1, L1, R2, R3, L5, L5, R4, L4, R2, R4, L3, R3, L3, R3, R4, R2, L1, R2, L3, L2, L1, R3, R5, L1, L4, R2, L4, R3, R1, R2, L5, R2, L189, R5, L5, R52, R3, L1, R4, R5, R1, R4, L1, L3, R2, L2, L3, R4, R3, L2, L5, R4, R5, L2, R2, L1, L3, R3, L4, R4, R5, L1, L1, R3, L5, L2, R76, R2, R2, L1, L3, R189, L3, L4, L1, L3, R5, R4, L1, R1, L1, L1, R2, L4, R2, L5, L5, L5, R2, L4, L5, R4, R4, R5, L5, R3, L1, L3, L1, L1, L3, L4, R5, L3, R5, R3, R3, L5, L5, R3, R4, L3, R3, R1, R3, R2, R2, L1, R1, L3, L3, L3, L1, R2, L1, R4, R4, L1, L1, R3, R3, R4, R1, L5, L2, R2, R3, R2, L3, R4, L5, R1, R4, R5, R4, L4, R1, L3, R1, R3, L2, L3, R1, L2, R3, L3, L1, L3, R4, L4, L5, R3, R5, R4, R1, L2, R3, R5, L5, L4, L1, L1
