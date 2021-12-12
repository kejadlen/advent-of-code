cave = Hash.new {|h,k| h[k] = [] }
ARGF.read.scan(/(\w+)-(\w+)/).each do
  cave[_1] << _2
  cave[_2] << _1
end

paths = [ %w[start] ]

loop do
  closed, open = paths.partition { _1.last == "end" }
  break if open.empty?

  paths = closed + open.flat_map {|path|
    cave.fetch(path.last)
      # .reject { _1 =~ /^[a-z]+$/ && path.include?(_1) }
      .reject { _1 == "start" }
      .map { path + [_1] }
      .reject {|path|
        small = path.tally.select { _1 =~ /^[a-z]+$/ }
        (small.count { _2 > 1 } > 1) || small.any? { _2 > 2 }
      }
  }
end

p paths.count
