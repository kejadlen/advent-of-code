class Integer
  def look_and_say
    self.to_s.chars.slice_when {|a,b| a != b }.map {|i| "#{i.size}#{i[0]}" }.join.to_i
  end
end

seed = 1113122113
50.times { seed = seed.look_and_say }
puts seed.to_s.size
