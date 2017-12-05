instructions = ARGF.read.strip.split("\n").map(&:to_i)
pc = 0
count = 0
while (0...instructions.size).cover?(pc)
  offset = instructions[pc]
  if offset >= 3
    instructions[pc] -= 1
  else
    instructions[pc] += 1
  end
  pc += offset
  count += 1
end
p count
