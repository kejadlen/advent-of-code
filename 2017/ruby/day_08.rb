instructions = ARGF.read.strip.scan(/(\w+) (dec|inc) (-?\d+) if (\w+) ([!<=>]+) (-?\d+)/m)
max = 0
registers = Hash.new(0)
instructions.each do |instruction|
  condition_value = registers[instruction[-3]]
  if eval("#{condition_value} #{instruction[-2]} #{instruction[-1]}")
    value = registers[instruction[0]]
    case instruction[1]
    when "inc"
      value += instruction[2].to_i
    when "dec"
      value -= instruction[2].to_i
    else
      raise instruction
    end
    registers[instruction[0]] = value
    max = [value, max].max
  end
end
p max
