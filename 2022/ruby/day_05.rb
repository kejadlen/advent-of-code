setup, moves = ARGF.read.split("\n\n")

setup = setup
  .lines(chomp: true)
  .map(&:chars)
  .transpose
  .select { _1.last =~ /\d/ }
  .map { _1[0..-2].join.strip.chars }

moves = moves.scan(/move (\d+) from (\d+) to (\d+)/).map { _1.map(&:to_i) }
moves.each do |n,from,to|
  # n.times {
  #   setup[to-1].unshift(setup[from-1].shift)
  # }
  setup[to-1].unshift(*setup[from-1].shift(n))
end

p setup.map(&:first).join
