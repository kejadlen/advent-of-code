require "strscan"

Part = Data.define(:number) do
  def eql?(other)
    self.object_id == other.object_id
  end
end

def parse(input)
  ss = StringScanner.new(input)
  y = x = 0
  schematic = {}
  until ss.eos?
    case
      when ss.scan(/\./)
        x += 1
      when num = ss.scan(/\d+/)
        coords = (0...num.length).map {|dx| [y, x+dx] }
        part = Part.new(num.to_i)
        schematic.merge!(coords.to_h { [_1, part] })
        x += num.length
      when ss.scan(/\n/)
        y += 1
        x = 0
      when sym = ss.scan(/./)
        schematic[[y,x]] = sym
        x += 1
      else
        fail
    end
  end
  schematic
end

schematic = parse(ARGF.read)
syms, nums = schematic.partition { String === _2 }.map(&:to_h)
neighboring_parts = ->((y,x)) {
  dy = (-1..1).to_a
  dx = (-1..1).to_a
  dy.product(dx)
    .map {|dy,dx| [y+dy,x+dx] }
    .filter_map { nums.fetch(_1, nil) }
}

# part one
p syms.keys.flat_map { neighboring_parts.(_1) }.uniq.sum(&:number)

# part two
p syms
  .select { _2 == ?* }
  .filter_map {|coord, _|
    parts = neighboring_parts.(coord).uniq
    parts.length == 2 ? parts : nil
  }
  .sum { _1.map(&:number).inject(:*) }
