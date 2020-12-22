require "strscan"

ss = StringScanner.new(ARGF.read)

rules = {}
mine = []
nearby = []

while ss.scan(/([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)\n/)
  c = ss.captures
  field = c.shift
  rules[field] = c.map(&:to_i).each_slice(2).map {|a,b| a..b }
end
ss.scan(/\n/)

ss.scan(/your ticket:\n/)
mine = ss.scan(/(?~\n)\n/).scan(/\d+/).map(&:to_i)

ss.scan(/\nnearby tickets:\n/)
nearby = ss.rest.split("\n").map {|line| line.split(?,).map(&:to_i) }

# part one
# p nearby.flat_map {|fields|
#   fields.reject {|field|
#     rules.values.any? {|values| values.any? {|range| range.cover?(field) }}
#   }
# }.sum

nearby.select! {|fields|
  fields.all? {|field|
    rules.values.any? {|values| values.any? {|range| range.cover?(field) }}
  }
}

valid = (0...mine.size).map {|i|
  rules.select {|name, ranges|
    nearby.map {|n| n[i] }.all? {|n| ranges.any? {|range| range.cover?(n) }}
  }
}.map.with_index {|v,i| [i, v.keys] }.to_h

order = {}
until valid.values.all?(&:empty?)
  k, f = valid.find {|_,v| v.size == 1 }
  order[k] = f[0]
  valid.transform_values! {|v| v - f }
end

p order
  .select {|_,v| v.start_with?("departure") }
  .map(&:first)
  .map {|i| mine[i] }
  .inject(&:*)
