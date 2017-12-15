start_a, start_b = ARGF.read.strip.scan(/\d+/).map(&:to_i)

class Generator
  def initialize(start, factor)
    @value = start
    @factor = factor
  end

  def each
    return enum_for(__method__) unless block_given?

    loop do
      @value *= @factor
      @value %= 2147483647
      yield @value
    end
  end
end

# start_a, start_b = 65, 8921
a = Generator.new(start_a, 16807).each.lazy
b = Generator.new(start_b, 48271).each.lazy

p a.zip(b).take(40_000_000).with_index.count {|(a,b),i|
  p i if i % 1_000_000 == 0
  # a.to_s(2)[-16,16] == b.to_s(2)[-16,16]
  a & 0b1111111111111111 == b & 0b1111111111111111
}
