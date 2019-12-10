require "pp"

asteroids = ARGF.read.strip.lines.map(&:strip).map {|l| l.chars }

max_y = asteroids.size
max_x = asteroids.first.size

asteroids = asteroids.flat_map.with_index {|row, y|
  row.filter_map.with_index {|l, x| l == ?. ? nil : [x, y] }
}

asteroids = asteroids.each.with_object({}) {|(x, y), h|
  visible = asteroids
    .reject {|ax, ay| [x, y] == [ax, ay] }
    .each.with_object(Hash.new {|h,k| h[k] = [] }) {|(ax, ay), ah|
      rad = (Math.atan2(ax - x, y - ay) + 2*Math::PI) % (2*Math::PI)
      ah[rad] << [ax, ay]
    }

  h[[x, y]] = visible
}

station = asteroids.max_by {|_,v| v.size }
# p station.last.size

asteroids = station.last.to_h.sort_by(&:first).map(&:last)
199.times do
  a = asteroids.shift
  asteroids.concat(a[1..-1]) if a.first.is_a?(Array)
end
x, y = asteroids.first.first
p 100*x + y
