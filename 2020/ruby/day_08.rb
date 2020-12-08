require "set"

class Program
  attr_reader :accumulator

  def initialize(instructions)
    @instructions = instructions
    @accumulator = 0
    @pc = 0
  end

  def run
    seen = Set.new

    loop do
      break if @pc == @instructions.size

      fail if seen.include?(@pc)
      seen << @pc

      op, arg = @instructions.fetch(@pc)
      case op
      when :acc
        @accumulator += arg
        @pc += 1
      when :jmp
        @pc += arg
      when :nop
        @pc += 1
      else
        fail
      end
    end
  end
end

instructions = ARGF.read.scan(/(\w+) ([-+]\d+)/).map {|op,arg| [op.to_sym, arg.to_i] }
uncorrupt = { nop: :jmp, jmp: :nop }
(0...instructions.size).select {|i|
  op, _ = instructions.fetch(i)
  uncorrupt.has_key?(op)
}.map {|i|
  attempt = instructions.clone
  instruction = attempt.fetch(i)
  attempt[i] = [uncorrupt.fetch(instruction[0]), instruction[1]]
  attempt
}.each do |i|
  program = Program.new(i)
  begin
    program.run
  rescue
    next
  end
  puts "accumulator: #{program.accumulator}"
end
