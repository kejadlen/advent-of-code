# typed: ignore

require "minitest/autorun"

require_relative "computer"

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
    assert_equal 1, run_program("3,50,99", input: "1")[50]

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

  def test_relative_base
    program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    output = StringIO.new
    run_program(program, output: output)
    assert_equal program.split(?,).join("\n"), output.string.strip

    output = StringIO.new
    run_program("1102,34915192,34915192,7,4,7,99,0", output: output)
    assert_equal 16, output.string.strip.size

    output = StringIO.new
    run_program("104,1125899906842624,99", output: output)
    assert_equal 1125899906842624, output.string.to_i
  end

  private

  def run_program(p, input: "", output: StringIO.new)
    Computer.from(p).run(
      StringIO.new(input),
      output,
    )
  end
end
