grove = {}
ARGF.read.lines(chomp: true).each.with_index do |row, y|
  row.chars.each.with_index do |c, x|
    grove[[y,x]] = c == ?#
  end
end

dirs = [
  [[-1, -1], [-1,  0], [-1,  1]],
  [[ 1, -1], [ 1,  0], [ 1,  1]],
  [[-1, -1], [ 0, -1], [ 1, -1]],
  [[-1,  1], [ 0,  1], [ 1,  1]],
]

(1..).each do |i|
  proposals = grove.select { _2 }
    .to_h {|(y,x),_|
      to = if dirs.flatten(1).none? {|dy,dx| grove[[y+dy, x+dx]] }
             [y, x]
           elsif dir = dirs.find {|adj| adj.none? {|dy,dx| grove[[y+dy, x+dx]] }}
             dy, dx = dir[1]
             [y+dy, x+dx]
           else
             [y, x]
           end
      [[y,x], to]
    }

  proposals.each.with_object(Hash.new {|h,k| h[k] = []}) {|(from, to), conflicts|
    conflicts[to] << from
  }.select { _2.size > 1 }.values.flatten(1).each do |elf|
    proposals[elf] = elf
  end

  if proposals.all? { _1 == _2 }
    puts i
    exit
  end

  proposals.each do |from, to|
    grove[from] = false
    grove[to] = true
  end

  dirs.push(dirs.shift)
end

# y = grove.select { _2 }.keys.map(&:first).minmax
# x = grove.select { _2 }.keys.map(&:last).minmax
# p Range.new(*y).sum {|y| Range.new(*x).count {|x| !grove[[y,x]] }}
