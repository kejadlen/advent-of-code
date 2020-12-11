layout = ARGF.read.split("\n").map(&:chars)
Y_MAX = layout.size
X_MAX = layout.first.size

# NEIGHBORS = (-1..1).flat_map {|y| (-1..1).map {|x| [y, x] }} - [[0, 0]]

# def tick(layout)
#   (0...Y_MAX).map {|y|
#     (0...X_MAX).map {|x|
#       occupied = NEIGHBORS
#         .map {|dy,dx| [y+dy, x+dx] }
#         .select {|y,x| (0...Y_MAX).cover?(y) && (0...X_MAX).cover?(x) }
#         .select {|y,x| layout[y][x] == ?# }
#         .count
#       case layout[y][x]
#       when ?.
#         ?.
#       when ?L
#         occupied == 0 ? ?# : ?L
#       when ?#
#         occupied >= 4 ? ?L : ?#
#       else
#         fail
#       end
#     }
#   }
# end

DIRS = (-1..1).flat_map {|y| (-1..1).map {|x| [y, x] }} - [[0, 0]]

def tick(layout)
  (0...Y_MAX).map {|y|
    (0...X_MAX).map {|x|
      next ?. if layout[y][x] == ?.
      occupied = DIRS
        .map {|dy,dx|
          (1..)
            .lazy
            .map {|i| [dy*i+y, dx*i+x] }
            .map {|y,x|
              if (0...Y_MAX).cover?(y) && (0...X_MAX).cover?(x)
                layout[y][x]
              else
                nil
              end
            }
            .find {|s| s != ?. }
        }
        .select {|s| s == ?# }
        .count
      case occupied
      when 0
        ?#
      when (5..)
        ?L
      else
        layout[y][x]
      end
    }
  }
end

loop do
  next_layout = tick(layout)
  break if next_layout == layout
  layout = next_layout

  puts layout.map(&:join).join("\n")
  puts
end

p layout.map {|row| row.count(?#) }.sum
