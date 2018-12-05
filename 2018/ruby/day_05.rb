input = ARGF.read.chomp

REGEX = Regexp.new(
  (?a..?z)
    .map {|x| [x, x.upcase] }
    .flat_map(&:permutation)
    .flat_map(&:to_a)
    .map(&:join)
    .join(?|)
)

def react(polymer)
  last = nil
  until polymer == last
    last = polymer
    polymer = polymer.gsub(REGEX, "")
  end
  polymer
end

# Part One
# p react(input).size

# Part Two
p (?a..?z)
  .map {|unit| input.gsub(/#{unit}/i, "") }
  .map {|polymer| react(polymer) }
  .map {|reacted| reacted.size }
  .min
