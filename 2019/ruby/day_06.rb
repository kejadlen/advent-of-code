# typed: false
orbits = ARGF
  .read.split("\n").map {|l| l.split(?)) }
  .each.with_object(Hash.new {|h,k| h[k] = []}) {|(a, b), o|
    o[a] << b
  }

roots = orbits.keys.select {|x| orbits.values.none? {|v| v.include?(x) }}

depths = {}
queue = roots.map {|x| [x, []] }
until queue.empty?
  x, a = queue.shift
  depths[x] = a
  a = a + [x]
  queue.concat(orbits.fetch(x) { [] }.map {|y| [y, a] })
end

# p depths.values.map(&:size).sum

you = depths.fetch("YOU")
san = depths.fetch("SAN")
p ((you + san) - (you & san)).size
