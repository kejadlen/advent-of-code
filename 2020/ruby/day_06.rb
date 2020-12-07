p ARGF.read.split("\n\n").map {|group|
  group.split("\n").map(&:chars)
}.map {|group|
  # group.inject(&:|)
  group.inject(&:&)
}.map(&:size).sum
