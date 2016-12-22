Node = Struct.new(*%i[x y size used avail use])

nodes = ARGF
  .read
  .scan(%r|/dev/grid/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s*(\d+)%|)
  .map {|match| Node.new(*match.map(&:to_i)) }

p nodes.permutation(2).count {|a,b|
  a.used != 0 && a.used <= b.avail
}
