Elf = Struct.new(:id, :presents)

n = 3017957
elves = Array.new(n) {|i| Elf.new(i+1, 1) }

until elves.size == 1
  elf = elves.shift
  next if elf.presents.zero?

  elf.presents += elves.first.presents
  elves.first.presents = 0

  elves << elf
end

p elves
