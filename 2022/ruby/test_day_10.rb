require "minitest/autorun"

def exec(instructions)
  return enum_for(__method__, instructions) unless block_given?

  x = 1
  instructions.each do |instruction|
    case instruction
    when /noop/
      yield x
    when /addx (-?\d+)/
      yield x
      yield x
      x += $1.to_i
    else
      fail "invalid instruction: #{instruction}"
    end
  end
  yield x
end

class TestDay10 < Minitest::Test
  def test_example
    assert_equal [1, 1, 1, 4, 4, -1], exec(<<~PROG.lines(chomp: true)).to_a
      noop
      addx 3
      addx -5
    PROG
  end
end
