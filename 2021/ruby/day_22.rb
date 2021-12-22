require "set"

steps = ARGF.read.scan(/(on|off) x=(.+),y=(.+),z=(.+)/)
  .map {|power, *ranges| [power == "on", *ranges.map { eval(_1) }] }
  # .select {|_, *ranges| ranges.all? { _1.begin >= -50 && _1.end <= 50 }}

# reactor = Hash.new(false)
# steps.each do |power,x,y,z|
#   x.each do |x|
#     y.each do |y|
#       z.each do |z|
#         reactor[[x,y,z]] = power
#       end
#     end
#   end
# end

# p reactor.count { _2 }

# xs = steps.flat_map { [_2.begin, _2.end] }.minmax
# ys = steps.flat_map { [_3.begin, _3.end] }.minmax
# zs = steps.flat_map { [_4.begin, _4.end] }.minmax
# ons = Range.new(*xs).sum {|x| Range.new(*ys).sum {|y| Range.new(*zs).count {|z|
#   step = steps.find { _2.cover?(x) && _3.cover?(y) && _4.cover?(z) }
#   step ? step[0] : false
# }}}

# p ons

class Range
  def overlap(other)
    if cover?(other.begin)
      min = other.begin
      max = [self.end, other.end].min
      (min..max)
    elsif cover?(other.end)
      min = [self.begin, other.begin].max
      max = other.end
      (min..max)
    elsif other.cover?(self.begin)
      min = self.begin
      max = [self.end, other.end].min
      (min..max)
    elsif other.cover?(self.end)
      min = [self.begin, other.begin].max
      max = self.end
      (min..max)
    else
      nil
    end
  end

  def split(other)
    overlap = self.overlap(other)
    return [] if overlap.nil?

    splits = [ overlap ]
    splits << (self.begin..overlap.begin-1) if overlap.begin > self.begin
    splits << (overlap.end+1..self.end)     if overlap.end < self.end
    splits
  end
end

Cube = Struct.new(:xs, :ys, :zs) do
  def -(other)
    return self unless o = overlap(other)

    xxs = xs.split(other.xs)
    yys = ys.split(other.ys)
    zzs = zs.split(other.zs)

    cuboids = xxs.flat_map {|x| yys.flat_map {|y| zzs.map {|z|
      Cube.new(x, y, z)
    }}}
    cuboids.delete(o)

    cuboids
  end

  def overlap(other)
    overlaps = to_a.zip(other.to_a).map { _1.overlap(_2) }
    return nil if overlaps.any?(&:nil?)

    Cube.new(*overlaps)
  end

  def overlap?(other) = !overlap(other).nil?

  def volume = (xs.end - xs.begin + 1) * (ys.end - ys.begin + 1) * (zs.end - zs.begin + 1)

  def to_s = "[#{[xs, ys, zs].map(&:to_s).join(", ")}]"
  alias_method :inspect, :to_s
end

steps = steps.map {|power, *ranges| [power, Cube.new(*ranges)] }

reactor = Set.new
steps.each do |power, cube|
  reactor
    .select { _1.overlap?(cube) }
    .each do |overlap|
      reactor.delete(overlap)
      reactor.merge(overlap - cube)
    end

  reactor << cube if power
end

p reactor.sum(&:volume)
