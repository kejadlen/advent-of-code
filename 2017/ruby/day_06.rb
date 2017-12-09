require "set"

class Day6
  def initialize(banks)
    @banks = banks
  end

  def each
    return enum_for(__method__) unless block_given?

    loop do
      yield @banks.dup

      value, i = @banks.map.with_index.max_by(&:first)
      @banks[i] = 0
      value.times do |offset|
        @banks[(i+offset+1) % @banks.size] += 1
      end
    end
  end
end

banks = ARGF.read.strip.split("\t").map(&:to_i)
day6 = Day6.new(banks).each.lazy
seen = Set.new
needle, i = day6.with_index.find {|config,_|
  if seen.include?(config)
    true
  else
    seen << config
    false
  end
}

p i
p day6.with_index.drop(1).find {|config,_| config == needle }.last
