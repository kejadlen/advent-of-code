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
  }
}

intersections = wire_points[0] & wire_points[1]
intersections.delete([0, 0])

distances = intersections.map {|(x, y)| x.abs + y.abs }
puts distances.min
