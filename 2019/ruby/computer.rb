OPCODES = {
  1 => ->(m, a, b, c) { m[c] = m[a] + m[b] },
  2 => ->(m, a, b, c) { m[c] = m[a] * m[b] },
  99 => ->(*) { throw :halt },
}

class Computer
  def self.from(input)
    new(input.split(?,).map(&:to_i))
  end

  def initialize(program)
    @memory = program
    @pc = 0
  end

  def run
    each.inject(nil) {|_,i| i }
  end

  def each
    return enum_for(__method__) unless block_given?

    catch(:halt) do
      loop do
        opcode = OPCODES.fetch(@memory.fetch(@pc))
        @pc += 1

        n = opcode.arity - 1
        args = (0...n).map {|i| @memory.fetch(@pc + i) }
        @pc += n

        opcode.call(@memory, *args)

        yield @memory
      end
    end
  end
end

require "minitest"

class TestComputer < Minitest::Test
  def test_samples
    c = Computer.from("1,9,10,3,2,3,11,0,99,30,40,50").each

    assert_equal 70, c.next.fetch(3)
    assert_equal 3500, c.next.fetch(0)
  end

  def test_more_samples
    run = ->(p) { Computer.from(p).run }

    assert_equal 2, run.call("1,0,0,0,99").fetch(0)
    assert_equal 6, run.call("2,3,0,3,99").fetch(3)
    assert_equal 9801, run.call("2,4,4,5,99,0").fetch(5)
    assert_equal 30, run.call("1,1,1,4,99,5,6,0,99").fetch(0)
  end
end

if __FILE__ == $0
  require "minitest/autorun"
end
