input = ARGF.read.strip
# input = <<INPUT
# 0: 3
# 1: 2
# 4: 4
# 6: 4
# INPUT
@input = Hash[input.scan(/(\d+): (\d+)/).map {|x| x.map(&:to_i) }]

class Firewall
  def initialize(input)
    @layers = input
    @scanners = Hash[input.map {|d,_| [d, 0] }]
    @deltas = Hash[input.map {|d,_| [d, 1] }]
  end

  def each
    return enum_for(__method__) unless block_given?

    loop do
      yield @scanners

      @layers.each do |depth, range|
        @scanners[depth] += @deltas[depth]
        @deltas[depth] = case @scanners[depth]
                         when 0
                           1
                         when range - 1
                           -1
                         else
                           @deltas[depth]
                         end
      end
    end
  end

end

def pass?(delay)
  f = Firewall.new(@input).each
  delay.times do
    f.next
  end

  severity = 0
  (0..@input.map(&:first).max).each do |pos|
    scanners = f.next
    return false if scanners[pos] == 0
  end
  true
end

def s(t, r)
  r - (t % (2*r) - r).abs
end

(0..Float::INFINITY).each do |delay|
  if @input.all? {|d,r| s(d + delay, r-1) != 0 }
    p delay
    exit
  end
end
