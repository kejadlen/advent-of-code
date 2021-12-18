require "strscan"

def add(a, b)
  reduced("[#{a},#{b}]")
end

def reduced(s)
  last_s = ""
  until s == last_s
    last_s = s

    to_explode = find_nested(s)
    if to_explode
      s = explode(s, to_explode)
      next
    end

    s = s.sub(/[1-9]\d+/) {|n|
      half = n.to_i / 2.0
      pair = [half.floor, half.ceil]
      "[#{pair.join(?,)}]"
    }
  end
  s
end

def find_nested(s)
  ss = StringScanner.new(s)

  depth = 0
  until ss.eos?
    case
    when ss.scan(/\[/)
      if depth == 4
        a = ss.pos-1
        ss.scan(/\d+,\d+\]/)
        b = ss.pos-1
        return [a, b]
      end
      depth += 1
    when ss.scan(/\]/)
      depth -= 1
    when ss.scan(/\d+|,/)
      # no-op
    else
      fail
    end
  end

  nil
end

def explode(s, pair_range)
  a, b = pair_range
  pair = s[a..b].scan(/\d+/).map(&:to_i)

  [
    s[0...a].reverse.sub(/\d+/) { (_1.reverse.to_i + pair[0]).to_s.reverse }.reverse,
    0,
    s[b+1..].sub(/(\d+)/) { _1.to_i + pair[1] },
  ].join
end

class Array
  def magnitude
    3*self[0].magnitude + 2*self[1].magnitude
  end
end

class Integer
  def magnitude
    self
  end
end

# sum = ARGF.read.split("\n").reject(&:empty?).inject {|sum,num| add(sum, num) }
# p eval(sum).magnitude

p ARGF.read.split("\n").reject(&:empty?).permutation(2).map { eval(add(*_1)).magnitude }.max
