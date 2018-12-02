require "set"

seen = Set.new
ARGF.read.lines.map(&:to_i).cycle.each.with_object([0]) do |i,n|
  n[0] += i
  p n[0] and exit if seen.include?(n[0])
  seen << n[0]
end
