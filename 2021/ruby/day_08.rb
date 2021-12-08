require "set"

input = ARGF.read.split("\n").map {|x| x.split(/\s+\|\s+/).map {|x| x.split(/\s+/) } }
# output = input.map(&:last)
# p output.flatten.count {|x| [2, 4, 3, 7].include?(x.length) }

MAP = {
  %w[ a b c   e f g ] => 0,
  %w[     c     f   ] => 1,
  %w[ a   c d e   g ] => 2,
  %w[ a   c d   f g ] => 3,
  %w[   b c d   f   ] => 4,
  %w[ a b   d   f g ] => 5,
  %w[ a b   d e f g ] => 6,
  %w[ a   c     f   ] => 7,
  %w[ a b c d e f g ] => 8,
  %w[ a b c d   f g ] => 9,
#     8 6 8 7 4 9 7
}.transform_keys(&:to_set)

def solve(signals, output)
  all = signals + output
  one = all.find {|x| x.length == 2 }
  four = all.find {|x| x.length == 4 }
  seven = all.find {|x| x.length == 3 }
  eight = all.find {|x| x.length == 7 }

  b = (?a..?g).find {|x| signals.count {|s| s.include?(x) } == 6 }
  e = (?a..?g).find {|x| signals.count {|s| s.include?(x) } == 4 }
  f = (?a..?g).find {|x| signals.count {|s| s.include?(x) } == 9 }

  a = (seven.chars - one.chars)[0]
  c = (one.chars - [f])[0]
  d = (four.chars - [b, c, f])[0]
  g = (eight.chars - [a, b, c, d, e, f])[0]

  map = { a: a, b: b, c: c, d: d, e: e, f: f, g: g }.invert

  output.map {|x| MAP.fetch(x.chars.map {|c| map.fetch(c).to_s }.to_set) }.join.to_i
end

p input.sum {|x| solve(*x) }
