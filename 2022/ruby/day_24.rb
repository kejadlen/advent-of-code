require "set"

walls = Set.new
blizzards = Hash.new {|h,k| h[k] = Set.new }
clear_ground = Set.new

ARGF.read.lines(chomp: true).each.with_index do |row, y|
  row.chars.each.with_index do |pos,x|
    case pos
    when ?#
      walls.add([y,x])
    when /[v^<>]/
      blizzards[pos].add([y,x])
    when ?.
      clear_ground.add([y,x])
    else
      fail pos
    end
  end
end

x_range = Range.new(*walls.map(&:last).minmax)
y_range = Range.new(*walls.map(&:first).minmax)

debug = ->() do
  puts
  puts y_range.map {|y|
    x_range.map {|x|
      if walls.include?([y,x])
        ?#
      elsif blizzards.any? {|_,pos| pos.include?([y,x])} 
        b = blizzards.select {|_,pos| pos.include?([y,x])}
        (b.size == 1) ? b.keys[0] : b.size
      else
        ?.
      end
    }.join
  }.join("\n")
end

start = [0, clear_ground.find {|y,x| y == 0 }.last]
goal = [y_range.end, clear_ground.find {|y,x| y == y_range.end }.last]

dir_deltas = {
  ?^ => [-1,  0],
  ?v => [ 1,  0],
  ?< => [ 0, -1],
  ?> => [ 0,  1],
}
moves = [*dir_deltas.values, [0, 0]]

frontier = [start]
(1..).each do |time|
  if (time % 1).zero?
    puts time
    # p frontier
    # debug.()
  end

  blizzards = blizzards.to_h {|dir,positions|
    delta = dir_deltas.fetch(dir)
    edges, positions = positions
      .map {|pos| pos.zip(delta).map { _1 + _2 }}
      .partition { walls.include?(_1) }
    positions.concat(edges.map {|(y,x)|
      case dir
      when ?^ then [y_range.end - 1, x]
      when ?v then [y_range.begin + 1, x]
      when ?< then [y, x_range.end - 1]
      when ?> then [y, x_range.end + 1]
      else fail dir
      end
    })
    [dir, positions]
  }

  clear_ground = y_range.map {|y| x_range.map {|x| [y, x] }}.flatten(1)
    .reject {|pos| walls.include?(pos) || blizzards.any? { _2.include?(pos) }}

  options = frontier.map {|current|
    moves.filter_map {|delta|
      pos = current.zip(delta).map { _1 + _2 }
      clear_ground.include?(pos) && pos
    }
  }.flatten(1)

  frontier = options.uniq

  if frontier.include?(goal)
    puts time + 1
    exit
  end
end
