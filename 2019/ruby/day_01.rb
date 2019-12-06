# typed: false
# puts ARGF.read.lines.map(&:to_i).map {|mass|
#   (mass / 3.0).floor - 2
# }.sum

fuel = ->(mass) {
  total = 0
  loop do
    mass = (mass / 3.0).floor - 2
    break if mass <= 0
    total += mass
  end
  total
}

puts ARGF.read.lines.map(&:to_i).map(&fuel).sum
