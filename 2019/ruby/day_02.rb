OPCODES = ARGF.read.split(?,).map(&:to_i)

# opcodes[1] = 12
# opcodes[2] = 2

# pc = 0
# loop do
#   p opcodes
#   case opcodes[pc]
#   when 1
#     opcodes[opcodes[pc+3]] = opcodes[opcodes[pc+1]] + opcodes[opcodes[pc+2]]
#     pc += 4
#   when 2
#     opcodes[opcodes[pc+3]] = opcodes[opcodes[pc+1]] * opcodes[opcodes[pc+2]]
#     pc += 4
#   when 99
#     puts opcodes[0]
#     exit
#   end
# end

def run(noun, verb)
  memory = OPCODES.dup
  memory[1] = noun
  memory[2] = verb

  pc = 0
  loop do
    case memory[pc]
    when 1
      memory[memory[pc+3]] = memory[memory[pc+1]] + memory[memory[pc+2]]
      pc += 4
    when 2
      memory[memory[pc+3]] = memory[memory[pc+1]] * memory[memory[pc+2]]
      pc += 4
    when 99
      return memory[0]
    end
  end
end

(0..99).each do |noun|
  (0..99).each do |verb|
    value = run(noun, verb)
    puts 100 * noun + verb and exit if value == 19690720
  end
end
