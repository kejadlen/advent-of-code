input = ARGF.read.split("\n")
depart_time = input.shift.to_i
buses = input.shift.split(?,).map {|b| b != ?x ? b.to_i : nil }

# p buses.compact.map {|bus|
#   d = bus * ((depart_time / bus) + 1)
#   [bus, d - depart_time]
# }.min_by(&:last).inject {|a,b| a * b }

# shamelessly copied from https://rosettacode.org/wiki/Chinese_remainder_theorem#Ruby
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end
  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  if g != 1
    raise 'Multiplicative inverse modulo does not exist!'
  end
  x % et
end

def chinese_remainder(mods, remainders)
  max = mods.inject( :* )  # product of all moduli
  series = remainders.zip(mods).map{ |r,m| (r * max * invmod(max/m, m) / m) }
  series.inject( :+ ) % max
end

buses = buses.map.with_index.select {|b,_| b }
# p 0.step(by: buses[0][0]).lazy.find {|depart_time|
#   buses.all? {|b,i| (depart_time + i) % b == 0 }
# }

mods, remainders = buses.map {|b,i| [b, b-i] }.transpose
p chinese_remainder(mods, remainders)
