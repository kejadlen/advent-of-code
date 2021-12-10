require "strscan"

input = ARGF.read.split("\n")

class IllegalCharacter < StandardError
  attr_reader :char
  def initialize(char)
    @char = char
  end
end

def parse(line)
  ss = StringScanner.new(line)
  stack = []

  until ss.eos?
    case
    when ss.scan(/\(/)
      stack << ?(
    when ss.scan(/\[/)
      stack << ?[
    when ss.scan(/\{/)
      stack << ?{
    when ss.scan(/</)
      stack << ?<
    when ss.scan(/\)/)
      raise IllegalCharacter.new(?)) unless stack.pop == ?(
    when ss.scan(/\]/)
      raise IllegalCharacter.new(?]) unless stack.pop == ?[
    when ss.scan(/\}/)
      raise IllegalCharacter.new(?}) unless stack.pop == ?{
    when ss.scan(/>/)
      raise IllegalCharacter.new(?>) unless stack.pop == ?<
    else
      fail
    end
  end

  stack
end

# points = {
#   ?) => 3,
#   ?] => 57,
#   ?} => 1197,
#   ?> => 25137,
# }

# p input.sum {|line|
#   begin
#     parse(line)
#     0
#   rescue IllegalCharacter => e
#     points.fetch(e.char)
#   end
# }

POINTS = ")]}>".chars.map.with_index.to_h.transform_values { _1 + 1 }
def score(closing)
  total = 0
  closing.each do |char|
    total *= 5
    total += POINTS.fetch(char)
  end
  total
end

complements = "() [] {} <>".split(" ").map(&:chars).to_h
scores = input
  .map { parse(_1) rescue [] }
  .reject(&:empty?)
  .map {|remaining| remaining.reverse.map { complements.fetch(_1) }}
  .map { score(_1) }
p scores.sort.fetch(scores.length / 2)
