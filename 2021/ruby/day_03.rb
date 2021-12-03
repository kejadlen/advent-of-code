bits = ARGF.read.split("\n").map(&:chars)

gamma = bits.transpose.map {|a| a.tally.max_by(&:last).first }.join
epsilon = bits.transpose.map {|a| a.tally.min_by(&:last).first }.join
p gamma.to_i(2) * epsilon.to_i(2)

oxy = bits.clone
(0..oxy.first.length).each do |i|
  b = oxy.transpose.map {|a| a.tally.sort.reverse.max_by(&:last).first }[i]
  oxy.select! {|x| x[i] == b }
  break if oxy.length == 1
end
oxy = oxy.join.to_i(2)

co2 = bits.clone
(0..co2.first.length).each do |i|
  b = co2.transpose.map {|a| a.tally.sort.min_by(&:last).first }[i]
  co2.select! {|x| x[i] == b }
  break if co2.length == 1
end
co2 = co2.join.to_i(2)

p oxy * co2
