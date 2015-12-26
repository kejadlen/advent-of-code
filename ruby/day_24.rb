require "letters"

packages = DATA.read.split("\n").map(&:to_i)
total = packages.inject(:+)
weight = total/4

(2..packages.size).each do |i|
  puts i
  groups = packages.combination(i).select {|combo| combo.inject(:+) == weight }
  unless groups.empty?
    p groups.map {|g| g.inject(:*) }.sort[0,10]
    exit
  end
end
__END__
1
3
5
11
13
17
19
23
29
31
37
41
43
47
53
59
67
71
73
79
83
89
97
101
103
107
109
113
