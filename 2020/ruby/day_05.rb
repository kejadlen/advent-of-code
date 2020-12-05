id = proc {|r, c| r * 8 + c }

seats = ARGF.read.split("\n")
  .map {|pass| pass.tr("FB", "01").tr("LR", "01") }
  .map {|pass| pass.to_i(2) }
  .map {|pass|
    row = pass >> 3
    col = pass & 0b111
    [row, col]
  }
# p seats.map(&id).max # day 1

rows = seats.map(&:first).minmax
cols = seats.map(&:last).minmax
all_seats = Range.new(*rows).flat_map {|r|
  Range.new(*cols).map {|c|
    [r, c]
  }
}
seat = (all_seats - seats).find {|r,_| !rows.include?(r) }
p id[*seat]
