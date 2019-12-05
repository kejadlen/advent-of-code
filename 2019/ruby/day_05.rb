OPCODES = ARGF.read.split(?,).map(&:to_i)

def run(memory)
  pc = 0
  loop do
    instruction = memory[pc]
    return if instruction == 99

    p pc
    a, b, c, opcode = instruction.to_s.rjust(5, ?0).scan(/^(0|1)(0|1)(0|1)(\d\d)$/)[0].map(&:to_i)
    c = c.zero? ? memory[memory[pc+1]] : memory[pc+1]
    b = b.zero? ? memory[memory[pc+2]] : memory[pc+2]
    a = a.zero? ? memory[memory[pc+3]] : memory[pc+3]

    case opcode
    when 1
      memory[memory[pc+3]] = c + b
      pc += 4
    when 2
      memory[memory[pc+3]] = c * b
      pc += 4
    when 3
      memory[memory[pc+1]] = 5
      pc += 2
    when 4
      puts c
      pc += 2
    when 5
      if c.nonzero?
        pc = b
      else
        pc += 3
      end
    when 6
      if c.zero?
        pc = b
      else
        pc += 3
      end
    when 7
      memory[memory[pc+3]] = (c < b) ? 1 : 0
      pc += 4
    when 8
      memory[memory[pc+3]] = (c == b) ? 1 : 0
      pc += 4
    else
      fail "unrecognized instruction: #{instruction}"
    end
  end
end

run(OPCODES)
