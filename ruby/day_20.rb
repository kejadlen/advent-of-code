require "prime"

house = 1
while true
  house += 1

  factors = house.prime_division
  presents = factors.map {|f,x| (x+1).times.map {|i| f**i }.inject(:+) }.inject(:*)

  if presents >= 3600000
    puts house
    exit
  end
end
