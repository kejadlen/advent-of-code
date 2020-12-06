# p ARGF.read.split("\n\n").map {|g| g.gsub("\n", "").chars.uniq.count }.sum
p ARGF.read.split("\n\n").map {|group|
  people = group.split("\n").map(&:chars)
  first = people.shift
  first.count {|answer| people.all? {|answers| answers.include?(answer) }}
}.sum
