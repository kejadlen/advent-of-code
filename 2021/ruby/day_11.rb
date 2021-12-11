input = ARGF.read.split("\n").map { _1.chars.map(&:to_i) }
ys = (0...input.size)
xs = (0...input.fetch(0).size)
coords = ys.flat_map {|y| xs.map {|x| [y,x] }}
octopuses = coords.to_h {|y,x| [[y,x], input.fetch(y).fetch(x)] }

deltas = (-1..1).flat_map {|dy| (-1..1).map {|dx| [dy, dx] }}.reject { _1 == [0, 0] }
neighbors = ->(y, x) {
  deltas
    .map {|dy,dx| [y+dy, x+dx] }
    .select {|y,x| ys.cover?(y) && xs.cover?(x) }
}

# flashes = 0
# 100.times do
(1..).each do |i|
  octopuses.transform_values! { _1 + 1 }
  loop do
    flashing = octopuses.select { _2 == 10 }
    break if flashing.empty?
    flashing.each do |(y,x),_|
      octopuses[[y,x]] += 1
      neighbors.(y,x)
        .select {|y,x| octopuses.fetch([y,x]) < 10 }
        .each do |y,x|
          octopuses[[y,x]] += 1
        end
    end
  end
  puts i or exit if octopuses.values.all? { _1 > 9 }
  # flashes += octopuses.count { _2 > 9 }
  octopuses.transform_values! { _1 > 10 ? 0 : _1 }
end

# p flashes
