places = (0..).lazy.map { 5 ** _1 }
digits = { ?- => -1, ?= => -2 }

sum = ARGF.read.lines(chomp: true)
  .map {|snafu|
    snafu.reverse.chars
      .map { digits.fetch(_1, _1.to_i) }
      .zip(places)
      .map { _1 * _2 }
      .sum
  }.sum

n_places = places.slice_after { 2*_1 >= sum }.take(1).to_a.flatten.reverse

require "z3"

solver = Z3::Solver.new

n_places.each do |place|
  solver.assert Z3.Int(place.to_s) <= 2
  solver.assert Z3.Int(place.to_s) >= -2
end
solver.assert n_places.map { _1 * Z3.Int(_1.to_s) }.sum == sum

fail unless solver.satisfiable?
p n_places
  .map { solver.model[Z3.Int(_1.to_s)].to_i }
  .map { digits.invert.fetch(_1, _1) }
  .join
