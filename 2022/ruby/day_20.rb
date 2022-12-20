list = ARGF.read.lines(chomp: true).map(&:to_i)

list = list.map { _1 * 811589153 }

list = list.map.with_index { [_2, _1] }
10.times do
  (0...list.size).each do |i|
    j = list.index {|ii,_| ii == i }
    _, n = list.delete_at(j)
    j += n
    j %= list.size
    list.insert(j, [i, n])
  end
end

list = list.map(&:last)

i = list.index(0)
p [1000, 2000, 3000].sum { list.fetch((i + _1) % list.size) }
