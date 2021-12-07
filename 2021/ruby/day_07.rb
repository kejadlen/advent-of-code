positions = ARGF.read.split(?,).map(&:to_i)
min, max = positions.minmax
pos = (min..max).min_by {|i|
  # positions.sum {|p| (p - i).abs }
  positions.sum {|p| n = (p - i).abs; (n * (n + 1)) / 2 }
}

# p positions.sum {|p| (p - pos).abs }
p positions.sum {|p| n = (p - pos).abs; (n * (n + 1)) / 2 }
