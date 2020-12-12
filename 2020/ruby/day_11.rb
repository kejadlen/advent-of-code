class Layout
  def self.from(raw, &logic)
    seats = Hash.new
    raw.split("\n").each.with_index do |row,y|
      row.chars.each.with_index do |pos,x|
        seats[[y,x]] = false if pos == ?L
      end
    end
    self.new(seats, &logic)
  end

  attr_reader :seats, :y_max, :x_max

  def initialize(seats, &logic)
    @seats, @logic = seats, logic
    @y_max = @seats.keys.map(&:first).max
    @x_max = @seats.keys.map(&:last).max
  end

  def [](yx)
    @seats[yx]
  end

  def each
    return enum_for(__method__) unless block_given?

    loop do
      yield self
      seats = tick(&@logic)
      break if seats == @seats
      @seats = seats
    end
  end

  def tick
    @seats.keys.map {|yx|
      [yx, @logic[self, yx]]
    }.to_h
  end

  def to_s
    (0..@y_max).map {|y|
      (0..@x_max).map {|x|
        case @seats[[y,x]]
        when true then ?#
        when false then ?L
        when nil then ?.
        else fail
        end
      }.join
    }.join("\n")
  end
end

NEIGHBORS = (-1..1).flat_map {|y| (-1..1).map {|x| [y, x] }} - [[0, 0]]
day1 = ->(layout, yx) {
  y, x = yx
  occupied_neighbors = NEIGHBORS.filter_map {|dy,dx| layout[[y+dy, x+dx]] }
  if !layout[yx] && occupied_neighbors.empty?
    true
  elsif layout[yx] && occupied_neighbors.size >= 4
    false
  else
    layout[yx]
  end
}

day2 = ->(layout, yx) {
  y, x = yx
  occupied_neighbors = NEIGHBORS.filter_map {|dy,dx|
    (1..).lazy
      .map {|i| [y+dy*i, x+dx*i] }
      .find {|y,x|
        !(0..layout.y_max).cover?(y) ||
          !(0..layout.x_max).cover?(x) ||
          layout.seats.has_key?([y, x])
    }
  }.filter_map {|yx| layout[yx] }
  if !layout[yx] && occupied_neighbors.empty?
    true
  elsif layout[yx] && occupied_neighbors.size >= 5
    false
  else
    layout[yx]
  end
}

layout = Layout.from(ARGF.read, &day2)
layout.each.take_while(&:itself).last
puts layout.seats.count(&:last)
