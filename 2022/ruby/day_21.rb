monkeys = ARGF.read.lines(chomp: true).to_h {|line| line.split(": ") }

# part one
# monkeys.each do |name, body|
#   define_method(name) do
#     eval(body)
#   end
# end

# p root

# part two
sub_monkeys = monkeys.delete("root").split(" + ")
monkeys.delete("humn")

monkeys.each do |name, body|
  define_method(name) do
    eval(body)
  end
end

target, unknown = sub_monkeys.partition { eval(_1) rescue nil}.map(&:first)
target = eval(target)

monkeys = monkeys.to_h {|monkey, job|
  a, op, b = job.split(" ")
  [monkey, { op:, a:, b: }]
}
monkeys["humn"] = { op: :humn }

def apply(monkeys, monkey)
  job = monkeys.fetch(monkey)
  case op = job.fetch(:op)
  when nil
    job.fetch(:a).to_i
  when :humn
    :humn
  else
    a = apply(monkeys, job.fetch(:a))
    b = apply(monkeys, job.fetch(:b))
    if a.is_a?(Integer) && b.is_a?(Integer)
      eval([a, op, b].join(" "))
    else
      [job.fetch(:op), a, b]
    end
  end
end

tree =  apply(monkeys, unknown)

def reverse(target, tree)
  loop do
    case tree
    in :humn
      return target
    in [op, Integer, b]
      a = tree.fetch(1)
      case op
      when ?* then target /= a
      when ?+ then target -= a
      when ?- then target = a - target
      else         fail tree.inspect
      end
      tree = b
    in [op, a, Integer]
      b = tree.fetch(2)
      case op
      when ?- then target += b
      when ?/ then target *= b
      when ?* then target /= b
      when ?+ then target -= b
      else         fail tree.inspect
      end
      tree = a
    else
      fail tree.inspect
    end
  end
end

p reverse(target, tree)
