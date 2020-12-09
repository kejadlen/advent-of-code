require "set"

execute = ->(r, op, arg) {
  delta = case op
          when :acc
            { acc: arg, pc: 1 }
          when :jmp
            { pc: arg }
          when :nop
            { pc: 1 }
          else
            fail
          end

  r.merge(delta) {|_, old, new| old + new }
}

# part 1
seen = Set.new
detect_loop = ->(r, op, arg) {
  throw :halt if seen.include?(r[:pc])
  seen << r[:pc]

  execute[r, op, arg]
}

instructions = ARGF.read.scan(/(\w+) ([-+]\d+)/).map {|op,arg| [op.to_sym, arg.to_i] }
registers = Hash.new(0)

swaps = { nop: :jmp, jmp: :nop }
candidates = instructions.filter_map.with_index {|(op, arg), i|
  swap = swaps[op]
  if swap.nil?
    nil
  else
    [i, [swap, arg]]
  end
}.map {|i, swap|
  candidate = instructions.clone
  candidate[i] = swap
  candidate
}

candidates.each do |candidate|
  seen = Set.new
  registers = Hash.new(0)
  catch(:halt) do
    while instruction = candidate[registers[:pc]]
      registers = detect_loop[registers, *instruction]
    end
  end
  break if registers[:pc] == candidate.size
end

p registers[:acc]
