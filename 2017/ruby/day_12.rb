require "set"
h = Hash[ARGF.read.strip.scan(/(\d+) <-> ([\d, ]+)/).map {|a,b| [a.to_i, b.scan(/\d+/).map(&:to_i)]}]
count = 0
until h.empty?
  key = h.keys.first
  foo = Set.new
  foo << key
  bar = [key]
  until bar.empty?
    baz = bar.shift
    bar = bar.concat(h[baz] - foo.to_a)
    foo = foo.merge(h[baz])
  end
  count += 1
  foo.each do |k|
    h.delete(k)
  end
end
p count
