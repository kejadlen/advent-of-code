class Probe
  def initialize(velocity, target)
    @velocity, @target = velocity, target
  end

  def each
    return enum_for(__method__) unless block_given?

    pos = [0,0]
    velocity = @velocity.clone

    loop do
      yield pos

      return if @target.zip(pos).all? { _1.cover?(_2) }

      pos = pos.zip(velocity).map { _1.sum }
      velocity[0] -= 1 if velocity[0] > 0
      velocity[1] -= 1

      return if pos[0] > @target[0].end
      return if pos[1] < @target[1].begin
    end
  end
end

input = ARGF.read.scan(/x=(.+), y=(.+)/)
target = input[0].map { eval(_1) }

haystack = (0..256).flat_map {|x| (-256..256).map {|y| [x, y] }}
haystack.select! {|v| Probe.new(v, target).each.any? {|pos| target.zip(pos).all? { _1.cover?(_2) }}}
# p haystack.map {|v| Probe.new(v, target).each.map { _2 }.max }.max
p haystack.count
