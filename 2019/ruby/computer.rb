# typed: false
OPCODES = {
  1  => ->(m, _, _, a, b, c) { m[c] = m[a] + m[b]           ; nil }, # add
  2  => ->(m, _, _, a, b, c) { m[c] = m[a] * m[b]           ; nil }, # multiply
  3  => ->(m, i, _, a)       { m[a] = i.gets.to_i           ; nil }, # input
  4  => ->(m, _, o, a)       { o.puts(m[a])                 ; nil }, # output
  5  => ->(m, _, _, a, b)    { m[a].nonzero? ? m[b]         : nil }, # jump-if-true
  6  => ->(m, _, _, a, b)    { m[a].zero? ? m[b]            : nil }, # jump-if-false
  7  => ->(m, _, _, a, b, c) { m[c] = (m[a] < m[b])  ? 1 : 0; nil }, # less than
  8  => ->(m, _, _, a, b, c) { m[c] = (m[a] == m[b]) ? 1 : 0; nil }, # equals
  99 => ->(*)                { throw :halt                        },
}

class Parameter
  def self.from(value)
    case value
    when Parameter
      value
    when Integer
      new(0, value)
    else
      raise "unexpected value: #{value}"
    end
  end

  attr_reader :value

  def initialize(mode, value)
    raise "unexpected mode: #{mode.inspect}" unless [0, 1].include?(mode)

    @mode, @value = mode, value
  end

  def position_mode?
    @mode.zero?
  end

  def immediate_mode?
    @mode.nonzero?
  end
end

class Computer
  def self.from(input)
    new(input.split(?,).map(&:to_i))
  end

  attr_reader :input, :output

  def initialize(program, input=STDIN, output=STDOUT)
    @memory, @input, @output = program.dup, input, output
    @pc = 0
  end

  def run(input=STDIN, output=STDOUT)
    each(input, output).inject(nil) {|_,i| i }
  end

  def each(input, output)
    return enum_for(__method__, input, output) unless block_given?

    catch(:halt) do
      loop do
        instruction = @memory[@pc].to_s.rjust(5, ?0)
        opcode = OPCODES.fetch(instruction[-2..-1].to_i)
        @pc += 1

        n = opcode.arity - 3
        args = (0...n).zip(instruction[0..2].reverse.chars.map(&:to_i)).map {|i, mode|
          value = @memory[@pc + i]
          Parameter.new(mode, value)
        }
        @pc += n

        @pc = opcode.call(self, input, output, *args) || @pc

        yield @memory
      end
    end
  end

  def [](parameter)
    parameter = Parameter.from(parameter)
    parameter.position_mode? ? @memory.fetch(parameter.value) : parameter.value
  end
  alias_method :fetch, :[]

  def []=(parameter, value)
    raise "writes should never be in immediate mode" if parameter.immediate_mode?

    @memory[parameter.value] = value
  end
end

require "minitest"

class TestComputer < Minitest::Test
  def test_samples
    c = Computer.from("1,9,10,3,2,3,11,0,99,30,40,50").each(StringIO.new, StringIO.new)

    assert_equal 70, c.next[3]
    assert_equal 3500, c.next[0]
  end

  def test_more_samples
    assert_equal 2, run_program("1,0,0,0,99")[0]
    assert_equal 6, run_program("2,3,0,3,99")[3]
    assert_equal 9801, run_program("2,4,4,5,99,0")[5]
    assert_equal 30, run_program("1,1,1,4,99,5,6,0,99")[0]
  end

  def test_parameter_modes
    assert_equal 99, run_program("1002,4,3,4,33")[4]
    assert_equal 99, run_program("1101,100,-1,4,0")[4]
  end

  def test_input_output
    assert_equal 1, run_program("3,50,99", input: "1\n")[50]

    output = StringIO.new
    run_program("4,3,99,50", output: output)
    assert_equal "50\n", output.string
  end

  def test_comparisons
    # Using position mode, consider whether the input is equal to 8; output 1
    # (if it is) or 0 (if it is not).
    { 7 => 0, 8 => 1, 9 => 0 }.each do |i, o|
      c = Computer.from("3,9,8,9,10,9,4,9,99,-1,8")
      output = StringIO.new
      c.run(StringIO.new(i.to_s), output)
      assert_equal "#{o}\n", output.string
    end

    # Using position mode, consider whether the input is less than 8; output 1
    # (if it is) or 0 (if it is not).
    { 7 => 1, 8 => 0, 9 => 0 }.each do |i, o|
      c = Computer.from("3,9,7,9,10,9,4,9,99,-1,8")
      output = StringIO.new
      c.run(StringIO.new(i.to_s), output)
      assert_equal "#{o}\n", output.string
    end

    # Using immediate mode, consider whether the input is equal to 8; output 1
    # (if it is) or 0 (if it is not).
    { 7 => 0, 8 => 1, 9 => 0 }.each do |i, o|
      c = Computer.from("3,3,1108,-1,8,3,4,3,99")
      output = StringIO.new
      c.run(StringIO.new(i.to_s), output)
      assert_equal "#{o}\n", output.string
    end

    # Using immediate mode, consider whether the input is less than 8; output 1
    # (if it is) or 0 (if it is not).
    { 7 => 1, 8 => 0, 9 => 0 }.each do |i, o|
      c = Computer.from("3,3,1107,-1,8,3,4,3,99")
      output = StringIO.new
      c.run(StringIO.new(i.to_s), output)
      assert_equal "#{o}\n", output.string
    end
  end

  def test_jumps
    { -1 => 1, 0 => 0, 1 => 1 }.each do |i, o|
      c = Computer.from("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9")
      output = StringIO.new
      c.run(StringIO.new(i.to_s), output)
      assert_equal "#{o}\n", output.string

      c = Computer.from("3,3,1105,-1,9,1101,0,0,12,4,12,99,1")
      output = StringIO.new
      c.run(StringIO.new(i.to_s), output)
      assert_equal "#{o}\n", output.string
    end
  end

  private

  def run_program(p, input: "", output: StringIO.new)
    Computer.from(p).run(
      StringIO.new(input),
      output,
    )
  end
end

if __FILE__ == $0
  require "minitest/autorun"
end
