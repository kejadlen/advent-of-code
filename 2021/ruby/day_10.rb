input = ARGF.read.split("\n")

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
      return { err: char } unless stack.pop == COMPLEMENTS.invert.fetch(char)
    end
  end

  { ok: stack }
end

# points = {
#   ?) => 3,
#   ?] => 57,
#   ?} => 1197,
#   ?> => 25137,
# }

# p input.sum {|line|
#   case parse(line)
#   in { ok: } then 0
#   in { err: } then points.fetch(err)
#   else fail
#   end
# }

def score(closing) = closing
  .map { COMPLEMENTS.values.index(_1) + 1 }
  .inject(0) {|n,i| n*5 + i }

scores = input
  .filter_map {|line|
    case parse(line)
    in { ok: } then ok
    in { err: } then nil
    else fail
    end
  }
  .map {|remaining| remaining.reverse.map { COMPLEMENTS.fetch(_1) }}
  .map { score(_1) }
p scores.sort.fetch(scores.length / 2)
