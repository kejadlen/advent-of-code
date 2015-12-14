regex = /(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds/
puts DATA.read.scan(regex).map { |name, speed, time, rest|
  distance = speed.to_i * time.to_i
  total_time = time.to_i + rest.to_i
  reps = 2503 / total_time

  total_distance = reps * distance + [2503 % total_time, time.to_i].min * speed.to_i
  [name, total_distance]
}.max {|a,b| a.last <=> b.last }
__END__
Dancer can fly 27 km/s for 5 seconds, but then must rest for 132 seconds.
Cupid can fly 22 km/s for 2 seconds, but then must rest for 41 seconds.
Rudolph can fly 11 km/s for 5 seconds, but then must rest for 48 seconds.
Donner can fly 28 km/s for 5 seconds, but then must rest for 134 seconds.
Dasher can fly 4 km/s for 16 seconds, but then must rest for 55 seconds.
Blitzen can fly 14 km/s for 3 seconds, but then must rest for 38 seconds.
Prancer can fly 3 km/s for 21 seconds, but then must rest for 40 seconds.
Comet can fly 18 km/s for 6 seconds, but then must rest for 103 seconds.
Vixen can fly 18 km/s for 5 seconds, but then must rest for 84 seconds.
