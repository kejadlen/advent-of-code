# typed: false
wire_paths = ARGF.read.lines.map {|l|
  l.split(?,).map {|i| [i[0], i[1..-1].to_i] }
}

wire_points = wire_paths.map {|path|
  path.each.with_object([[0, 0]]) {|(dir, length), points|
    x, y = points.last
    length.times {|i|
      points << case dir
                when ?R then [x+i+1, y]
                when ?U then [x, y+i+1]
                when ?L then [x-i-1, y]
                when ?D then [x, y-i-1]
                end
    }
  }.map.with_index.to_h
}

intersections = wire_points[0].select {|k, _| wire_points[1].has_key?(k) }
intersections.delete([0, 0])

# distances = intersections.map {|(x, y), _| x.abs + y.abs }
distances = intersections.map {|p, d| d + wire_points[1].fetch(p) }
puts distances.min
