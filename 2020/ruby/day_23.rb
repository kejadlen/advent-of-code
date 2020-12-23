cups = ARGF.read.chars.map(&:to_i)
cups_range = Range.new(*cups.minmax)

current = 0
100.times do
  current_value = cups.fetch(current % cups.size)

  pickup_indices = 3.times.map {|i| (current + i + 1) % cups.size }
  pickup = cups.values_at(*pickup_indices)
  pickup_indices.sort.reverse.each do |i|
    cups.delete_at(i)
  end

  dest_value = current_value - 1
  until cups_range.cover?(dest_value) && !pickup.include?(dest_value)
    dest_value -= 1
    dest_value = cups_range.end unless cups_range.cover?(dest_value)
  end


  dest_index = cups.index(dest_value)

  cups.insert(dest_index+1, *pickup)

  current = cups.index(current_value)
  current += 1
  current %= cups.size
end

i = cups.index(1)
p (cups[i+1..-1] + cups[0...i]).join
