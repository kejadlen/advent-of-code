# p ARGF.read.chomp.lines.map(&:chomp)

INPUT = 7400

FuelCell = Struct.new(*%i[ x y ]) do
  def rack_id
    x + 10
  end

  def power_level
    power_level = rack_id * y
    power_level += INPUT
    power_level *= rack_id
    power_level = power_level / 100 % 10
    power_level -= 5

    power_level
  end
end

grid = Hash.new(0)
(1..300).each {|x|
  (1..300).each {|y|
    grid[[x,y]] = FuelCell.new(x, y).power_level
  }
}

(44..48).each do |y|
  (32..36).each do |x|
    print " #{grid[[x,y]]} "
  end
  puts
end

squares = Hash.new(0)
(2..299).each {|x|
  (2..299).each {|y|
    power_level = [[-1, -1], [0, -1], [1, -1],
                   [-1, 0], [0, 0], [1, 0],
                   [-1, 1], [0, 1], [1, 1]].map {|(dx,dy)| grid[[x+dx, y+dy]] }.sum
    squares[[x,y]] = power_level
  }
}

p squares.max_by(&:last)
