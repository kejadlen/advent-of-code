input = ARGF.read.strip

def knot_hash(input)
  list = (0..255).to_a
  current = 0
  lengths = input.split(//).map(&:ord)
  lengths.concat([17, 31, 73, 47, 23])
  skip = 0
  64.times do
    lengths.each do |length|
      list[0, length] = list[0, length].reverse
      list = list.rotate(length + skip)
      current += length + skip
      current %= list.size
      skip += 1
    end
  end

  list = list.rotate(list.size - current)
  dense = list.each_slice(16).map {|slice| slice.inject(&:^) }
  hex = dense.map {|n| n.to_s(16).rjust(2, ?0) }.join
  hex.hex.to_s(2).rjust(128, ?0)
end

# p (0..127).map {|i| "#{input}-#{i}" }.map {|row| knot_hash(row) }.join.split(//).select {|c| c == ?1 }.count

# input = "flqrgnkx"
grid = (0..127).map {|i| "#{input}-#{i}" }.map {|row| knot_hash(row).split(//) }

regions = 0
queue = []
(0..127).each do |y|
  (0..127).each do |x|
    if grid[y][x] == ?1
      regions += 1
      grid[y][x] = ?0
      queue << [x, y]
      until queue.empty?
        xx,yy = queue.shift
        [[0, 1], [0, -1], [1, 0], [-1, 0]].each do |dx, dy|
          xxx = xx + dx
          yyy = yy + dy
          if (0..127).cover?(xxx) && (0..127).cover?(yyy) && grid[yyy][xxx] == ?1
            grid[yyy][xxx] = ?0
            queue << [xxx, yyy]
          end
        end
      end
    end
  end
end
p regions
