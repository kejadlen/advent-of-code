cups = Hash.new {|h,k|
  fail if k > 1000000
  h[k] = k + 1
}

cup_values = ARGF.read.chars.map(&:to_i)
current = cup_values.first

cup_values = [1_000_000, *cup_values, cup_values.max + 1]
cup_values.each_cons(2) do |a,b|
  cups[a] = b
end
cups_range = Range.new(*cups.keys.minmax)

10_000_000.times do |i|
  pickup = 2.times.inject([cups[current]]) {|p,_| p << cups[p.last] }
  cups[current] = cups[pickup.last]

  dest_value = current - 1
  loop do
    dest_value = cups_range.max if dest_value == 0
    break unless pickup.include?(dest_value)
    dest_value -= 1
  end

  cups[pickup.last] = cups[dest_value]
  cups[dest_value] = pickup.first

  current = cups[current]
end

p 1.times.inject([cups[1]]) {|p,_| p << cups[p.last] }.inject(&:*)
