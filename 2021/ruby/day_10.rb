input = ARGF.read.split("\n")

class IllegalCharacter < StandardError
  attr_reader :char
  def initialize(char)
    @char = char
  end
end

COMPLEMENTS = %w[ () [] {} <> ].map(&:chars).to_h
OPENING_REGEXP = Regexp.new("[#{Regexp.escape(COMPLEMENTS.keys.join)}]")
CLOSING_REGEXP = Regexp.new("[#{Regexp.escape(COMPLEMENTS.values.join)}]")
def parse(line)
  stack = []

  s = line.chars
  until s.empty?
    case char = s.shift
    when OPENING_REGEXP
      stack << char
    when CLOSING_REGEXP
      raise IllegalCharacter.new(char) unless stack.pop == COMPLEMENTS.invert.fetch(char)
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

def score(closing) = closing
  .map { COMPLEMENTS.values.index(_1) + 1 }
  .inject(0) {|n,i| n*5 + i }

scores = input
  .filter_map { parse(_1) rescue nil }
  .map {|remaining| remaining.reverse.map { COMPLEMENTS.fetch(_1) }}
  .map { score(_1) }
p scores.sort.fetch(scores.length / 2)
