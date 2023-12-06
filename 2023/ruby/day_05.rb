Conversion = Data.define(:source, :dest) do
  def [](k)
    return nil unless source.cover?(k)

    dest.begin + k - source.begin
  end
end

Mapping = Data.define(:conversions) do
  def [](source)
    conversions.filter_map { _1[source] }.first || source
  end
end

chunks = ARGF.read.split("\n\n")
seeds = chunks.shift.scan(/\d+/).map(&:to_i)
mappings = chunks.map {|chunk|
  Mapping.new(
    chunk
      .strip.split("\n")[1..-1]
      .map { _1.scan(/\d+/).map(&:to_i) }
      .map { Conversion.new((_2..._2+_3), (_1..._1+_3)) }
      # .sort_by { _1.source.begin }
  )
}

# part one
p seeds
  .map {|seed|
    mappings.inject(seed) {|cur, mapping| mapping[cur] }
  }
  .min

# part two

# clamps range a to range b
def clamp(a, b)
  case
  when a.cover?(b.begin) && a.cover?(b.end)
    b
  when b.cover?(a.begin) && b.cover?(a.end)
    a
  when a.cover?(b.begin)
    (b.begin...a.end)
  when b.cover?(a.begin)
    (a.begin...b.end)
  else
    nil
  end
end

seeds = seeds
  .each_slice(2)
  .map {|start, length| (start...start+length) }
  .sort_by(&:begin)
dests = mappings.inject(seeds) {|cur, mapping|
  sources = cur
    .flat_map {|range|
      sources = mapping.conversions.map(&:source).sort_by(&:begin)
      sources.concat(sources.each_cons(2).map { (_1.end..._2.begin) })
      sources << (0...(sources.map(&:begin).min))
      sources << (sources.map(&:end).max..)
      sources.filter_map {|source|
        clamp(source, range)
      }
    }
    .reject { _1.size == 0 }
  sources.map { (mapping[_1.begin]..mapping[_1.end-1]) }
}
p dests.map(&:begin).min

### prior explorations for part two

# p seeds
#   .each_slice(2)
#   .map {|start, length|
#     (start...start+length).map {|seed|
#       mappings.inject(seed) {|cur, mapping| mapping[cur] }
#     }
#     .min
#   }
#   .min

# seeds = seeds
#   .each_slice(2)
#   .map {|start, length| (start...start+length) }
reversed = mappings
  .map {|mapping|
    Mapping.new(
      mapping.conversions.map {|c|
        Conversion.new((c.dest.begin...c.dest.begin+c.source.size), c.source)
      }
    )
  }
  .reverse
# p (0..).find {|i|
#     source = reversed.inject(i) {|cur, mapping| mapping[cur] }
#     seeds.any? { _1.cover?(source) }
#   }

# seeds = seeds
#   .each_slice(2)
#   .map {|start, length| (start...start+length) }
lowest = seeds
  .flat_map(&:minmax)
  .filter_map {|seed|
    mappings.inject(seed) {|cur, mapping| mapping[cur] }
  }
  .min
p (0..lowest).bsearch {|loc|
    source = reversed.inject(loc) {|cur, mapping| mapping[cur] }
    seeds.any? { _1.cover?(source) }
  }

