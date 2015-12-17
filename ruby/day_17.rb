buckets = DATA.read.split("\n").map(&:to_i)
puts (1..buckets.size).map {|i| buckets.combination(i).select {|p| p.inject(:+) == 150 }.size }.inject(:+)
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
