INPUT = ARGF.read.chomp.to_i

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
(1..300).each do |x|
  (1..300).each do |y|
    grid[[x,y]] = FuelCell.new(x, y).power_level
  end
end

squares = Hash.new(0)
(1..300).each do |size|
  (1..(300-size+1)).each {|x|
    (1..(300-size+1)).each {|y|
      deltas = (0...size).flat_map {|d| [[size-1, d], [d, size-1]] }
      squares[[x,y,size]] = squares[[x,y,size-1]] + deltas.map {|(dx,dy)| grid[[x+dx, y+dy]] }.sum - grid[[x+size-1, y+size-1]]
    }
  }

  puts "#{size}: #{squares.max_by(&:last)}"
  squares.delete_if {|(_,_,s)| s < size }
end

