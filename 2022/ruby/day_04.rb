p ARGF.read.lines(chomp: true)
  .map { _1.split(?,) }
  .map {|x| x.map { _1.split(?-).map(&:to_i) }}
  .map {|(a,b),(x,y)| [(a..b), (x..y)] }
  # .count {|a,b| (a.cover?(b.begin) && a.cover?(b.end)) || (b.cover?(a.begin) && b.cover?(a.end)) }
  .count {|a,b| (a.cover?(b.begin) || a.cover?(b.end)) || (b.cover?(a.begin) || b.cover?(a.end)) }
