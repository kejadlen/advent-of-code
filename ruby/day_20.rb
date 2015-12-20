houses = Hash.new(0)

elf = 0
while true
  elf += 1

  50.times do |i|
    house = (i+1)*elf
    houses[house] += 11*elf

    if i.zero? && houses[house] >= 36000000
      puts house
      exit
    end
  end
end
