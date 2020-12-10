adapters = ARGF.read.scan(/\d+/).map(&:to_i)

outlet = 0
device = adapters.max + 3

dist = (adapters + [outlet, device]).sort.each_cons(2).map {|a,b| b - a }

# part 1
# tally = dist.tally
# p dist[1] * dist[3]

p dist
  .slice_when {|a,b| a != b }
  .select {|run| run.first == 1 }
  .map {|run| { 1 => 1, 2 => 2, 3 => 4, 4 => 7 }.fetch(run.size) }
  .inject {|a,b| a*b }
