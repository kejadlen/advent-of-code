Monkey = Struct.new(:id, :items, :operation, :test, :t, :f) do
  def throw_to(item)
    (item % test).zero? ? t : f
  end
end

MONKEY_RE = /Monkey (?<id>\d+):
  Starting items: (?<items>(?~\n))
  Operation: new = (?<op>(?~\n))
  Test: divisible by (?<test>\d+)
    If true: throw to monkey (?<t>\d+)
    If false: throw to monkey (?<f>\d+)/m

monkeys = ARGF.read.split("\n\n").map {|monkey|
  md = MONKEY_RE.match(monkey)
  fail if md.nil?

  Monkey.new(
    md[:id].to_i,
    md[:items].split(", ").map(&:to_i),
    md[:op],
    md[:test].to_i,
    md[:t].to_i,
    md[:f].to_i,
  )
}

max_worry = monkeys.map(&:test).inject(:*)

inspections = Hash.new(0)
# 20.times do
10_000.times do
  monkeys.each do |monkey|
    until monkey.items.empty?
      inspections[monkey.id] += 1

      item = monkey.items.shift
      old = item
      item = eval(monkey.operation)
      # item /= 3
      item %= max_worry
      to = monkey.throw_to(item)
      monkeys[to].items << item
    end
  end
end

p inspections.values.max(2).inject(:*)
