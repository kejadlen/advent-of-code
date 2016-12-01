class Reindeer
  attr_reader *%i[ speed time rest ]

  def initialize(speed, time, rest)
    @speed, @time, @rest = [speed, time, rest].map(&:to_i)
  end

  def distance(current_time)
    distance = speed * time
    total_time = time + rest
    reps = current_time / total_time

    reps * distance + [current_time % total_time, time].min * speed
  end
end

regex = /(\w+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds/
reindeer = DATA.read.scan(regex).each.with_object({}) {|(name, speed, time, rest), reindeer|
  reindeer[name] = Reindeer.new(speed, time, rest)
}

scores = (1..2503).each.with_object(Hash.new(0)) do |current_time, scores|
  sorted = reindeer.group_by {|_,r| r.distance(current_time) }.sort
  sorted.last.last.map(&:first).each do |name|
    scores[name] += 1
  end
end

puts scores.sort_by(&:last)
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
