require "strscan"

mem = Hash.new(0)
mask = nil

ss = StringScanner.new(ARGF.read)
until ss.eos?
  case
  when ss.scan(/mask = ([10X]+)\n/)
    mask = ss.captures.fetch(0)
  when ss.scan(/mem\[(\d+)\] = (\d+)\n/)
    addr, value = ss.captures.map(&:to_i)

    # part 1
    # value &= mask.gsub(?X, ?1).to_i(2)
    # value |= mask.gsub(?X, ?0).to_i(2)
    # mem[addr] = value

    masked = ("%036b" % addr).chars.zip(mask.chars).map {|a,m|
      case m
      when ?X then ?X
      when ?1 then ?1
      when ?0 then a
      else fail
      end
    }.join
    floating = masked.count(?X)
    (0...2**floating).map {|i| i.to_s(2).chars }.each do |i|
      floated = masked.gsub(?X) { i.pop || "0" }.to_i(2)
      mem[floated] = value
    end
  else
    fail
  end
end

p mem.values.sum
