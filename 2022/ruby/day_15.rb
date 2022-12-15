require "set"

sensors_and_beacons = ARGF.read
  .scan(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/)
  .map { _1.map(&:to_i) }
  .flatten
  .each_slice(2)

# part one
row = 2_000_000
# row = 10

no_beacons = []
sensors_and_beacons.each_slice(2) do |sensor, beacon|
  dist = sensor.zip(beacon).sum { (_1 - _2).abs }

  dy = (row - sensor[1]).abs
  next if dy > dist
  dx = dist - dy

  x_min, x_max = [sensor[0]-dx, sensor[0]+dx].sort

  no_beacons << (x_min..x_max)
end

# remove covered ranges
no_beacons = no_beacons.reject {|x| (no_beacons - [x]).any? { _1.cover?(x) }}

# merge ranges
no_beacons = no_beacons.inject([no_beacons.shift]) {|no_beacons, range|
  next no_beacons if no_beacons.any? { _1.cover?(range) }

  if overlap = no_beacons.find { _1.cover?(range.begin) }
    range = (overlap.end + 1..range.end)
  end

  if overlap = no_beacons.find { _1.cover?(range.end) }
    range = (range.begin..overlap.begin-1)
  end

  no_beacons << range
}

p no_beacons.sum(&:size) - sensors_and_beacons.to_a.select { _2 == row }.uniq.size

# part two
find_sab = ->(x, y) {
  sensors_and_beacons.each_slice(2).find {|sensor, beacon|
    dist = sensor.zip(beacon).sum { (_1 - _2).abs }
    dist >= sensor.zip([x, y]).sum { (_1 - _2).abs }
  }
}

max = 4_000_000
# max = 20
x = 0
y = 0
loop do
  p y if (y % 10_000).zero?

  sensor, _ = find_sab.(x, y)
  dx = sensor[0] - x
  if dx >= max / 2
    dy = sensor[1] - y
    y += dy.positive? ? 2 * dy + 1 : 1
  end

  loop do
    sensor, beacon = find_sab.(x, y)
    if sensor.nil?
      p 4_000_000 * x + y
      exit
    end

    dist = sensor.zip(beacon).sum { (_1 - _2).abs }
    dy = (sensor[1] - y).abs
    dx = (dist - dy).abs
    x = sensor[0] + dx + 1

    if x > max
      x = 0
      break
    end
  end
  y += 1
  break if y > max
end
