buckets = DATA.read.split("\n").map(&:to_i)
puts (1..buckets.size).flat_map {|i|
  buckets.combination(i).select {|p| p.inject(:+) == 150 }
}.group_by(&:size).sort_by(&:first).first.last.size
__END__
50
44
11
49
42
46
18
32
26
40
21
7
18
43
10
47
36
24
22
40
