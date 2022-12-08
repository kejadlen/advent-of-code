grid = ARGF.read.lines(chomp: true).map { _1.chars.map(&:to_i) }

def each(grid)
  return enum_for(__method__, grid) unless block_given?

  transposed = grid.transpose

  grid.each.with_index do |row, y|
    row.each.with_index do |tree, x|
      col = transposed[x]

      sight_lines = [
        (0...x).map { row[_1] }.reverse,
        (x+1...row.size).map { row[_1] },
        (0...y).map { col[_1] }.reverse,
        (y+1...row.size).map { col[_1] },
      ]

      yield tree, sight_lines
    end
  end
end

p each(grid).count {|tree, sight_lines|
  sight_lines.any? { _1.empty? || tree > _1.max }
}

p each(grid).map {|tree, sight_lines|
  sight_lines
    .map {|sl| sl.slice_after { _1 >= tree }.first }
    .compact
    .map(&:size)
    .inject(:*)
}.max
