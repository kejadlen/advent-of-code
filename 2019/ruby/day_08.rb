image = ARGF.read.scan(/\d/).map(&:to_i)

w = 25
h = 6

# l = image.each_slice(w*h).min_by {|l| l.count(0) }
# p l.count(1) * l.count(2)

layers = image.each_slice(w*h)
puts layers
  .inject {|n,l| n.zip(l) }
  .map(&:flatten)
  .map {|layers| layers.drop_while {|p| p == 2 }.first }
  .map {|p| p.zero? ? "█" : " " }
  .each_slice(w)
  .map(&:join)
  .join("\n")
