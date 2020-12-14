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

    addr |= mask.gsub(?X, ?0).to_i(2)
    floating = mask.reverse.chars.filter_map.with_index {|x,i|
      x == ?X ? i : nil
    }
    (0...2**floating.size).each do |i|
      floated = addr.to_s(2).rjust(36, ?0).reverse
      floating.each.with_index do |j,k|
        floated[j] = i[k].to_s
      end
      mem[floated.reverse.to_i(2)] = value
    end
  else
    fail
  end
end

p mem.values.sum
