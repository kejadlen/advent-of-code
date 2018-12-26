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

Instruction = Struct.new(:opcode, :args)

class Program
  def self.parse(input)
    lines = input.lines
    ip = lines.shift[/^#ip (\d)+$/, 1].to_i
    instructions = lines.map {|line|
      opcode, *args = line.split
      opcode = opcode.to_sym
      args = args.map(&:to_i)
      Instruction.new(opcode, args)
    }
    new(ip, instructions)
  end

  attr_reader :registers

  def initialize(ip, instructions)
    @ip, @instructions = ip, instructions
    @registers = Array.new(6, 0)
  end

  def run
    return enum_for(__method__) unless block_given?

    while (0...@instructions.length).cover?(@registers[@ip])
      instruction = @instructions.fetch(@registers[@ip])
      OPCODES.fetch(instruction.opcode)[*instruction.args][@registers]
      yield self
      @registers[@ip] += 1
    end
  end
end

class TestProgram < Minitest::Test
  def test_program
    program = Program.parse(<<~PROGRAM)
      #ip 0
      seti 5 0 1
      seti 6 0 2
      addi 0 1 0
      addr 1 2 3
      setr 1 0 0
      seti 8 0 4
      seti 9 0 5
    PROGRAM

    run = program.run
    loop do
      run.next
    end

    assert_equal [7, 5, 6, 0, 0, 9], program.registers
  end
end

def solve(input)
  program = Program.parse(input)
  run = program.run
  loop do
    run.next
  end
  program.registers[0]
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]

  puts solve(ARGF.read)
end
