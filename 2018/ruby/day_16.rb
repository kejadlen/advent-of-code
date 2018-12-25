require "minitest"
require "minitest/pride"

OPCODES = {
  addr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] + registers[b] } },
  addi: ->(a, b, c) { ->(registers) { registers[c] = registers[a] + b } },
  mulr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] * registers[b] } },
  muli: ->(a, b, c) { ->(registers) { registers[c] = registers[a] * b } },
  banr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] & registers[b] } },
  bani: ->(a, b, c) { ->(registers) { registers[c] = registers[a] & b } },
  borr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] | registers[b] } },
  bori: ->(a, b, c) { ->(registers) { registers[c] = registers[a] | b } },
  setr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] } },
  seti: ->(a, b, c) { ->(registers) { registers[c] = a } },
  gtir: ->(a, b, c) { ->(registers) { registers[c] = (a > registers[b]) ? 1 : 0 } },
  gtri: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] > b) ? 1 : 0 } },
  gtrr: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] > registers[b]) ? 1 : 0 } },
  eqir: ->(a, b, c) { ->(registers) { registers[c] = (a == registers[b]) ? 1 : 0 } },
  eqri: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] == b) ? 1 : 0 } },
  eqrr: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] == registers[b]) ? 1 : 0 } },
}

class TestOpcodes < Minitest::Test
  def test_mulr
    registers = [3, 2, 1, 1]

    OPCODES[:mulr].call(2, 1, 2).call(registers)

    assert_equal [3, 2, 2, 1], registers
  end

  def test_addi
    registers = [3, 2, 1, 1]

    OPCODES[:addi].call(2, 1, 2).call(registers)

    assert_equal [3, 2, 2, 1], registers
  end

  def test_seti
    registers = [3, 2, 1, 1]

    OPCODES[:seti].call(2, 1, 2).call(registers)

    assert_equal [3, 2, 2, 1], registers
  end
end

def solve(input)
  samples = input.scan(/
                       Before:\s*((?~\n))\n
                       ((?~\n))\n
                       After:\s*((?~\n))\n
                       /mx)
  samples.count {|sample|
    before = sample[0].scan(/\d+/).map(&:to_i)
    opcode = sample[1].scan(/\d+/).map(&:to_i)
    after = sample[2].scan(/\d+/).map(&:to_i)
    _, *args = opcode

    opcode_count = OPCODES.count {|_, instruction|
      registers = before.dup
      instruction[*args][registers]
      registers == after
    }
    opcode_count >= 3
  }
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]

  puts solve(ARGF.read)
end
