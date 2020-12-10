adapters = ARGF.read.scan(/\d+/).map(&:to_i)

outlet = 0
device = adapters.max + 3

dist = (adapters + [outlet, device]).sort.each_cons(2).map {|a,b| b - a }

# part 1
# tally = dist.tally
# p dist[1] * dist[3]

# programmatically figuring out the arrangements
# arrangements = Hash.new {|h,k|
#   h[k] = (0..k-1).flat_map {|n| (2..k).to_a.combination(n).to_a }
#     .reject {|c| (c << 1 << k+1).sort.each_cons(2).any? {|a,b| b-a > 3 }}
#     .count
# }

# tribonacci
arrangements = Hash.new {|h,k| h[k] = h[k-1] + h[k-2] + h[k-3] }
arrangements[0] = 1
arrangements[1] = 1
arrangements[2] = 2

p dist
  .slice_when {|a,b| a != b }
  .select {|run| run.first == 1 }
  .map {|run| arrangements[run.size] }
  .inject {|a,b| a*b }
