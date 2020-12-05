seats = ARGF.read.split("\n")
  .map {|pass| pass.tr("FB", "01").tr("LR", "01") }
  .map {|pass| pass.to_i(2) }
p seats.max # day 1

p (0b1000..).find {|id| !seats.include?(id) }
