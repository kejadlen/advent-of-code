Monkey = Struct.new(:id, :items, :operation, :test, :throw_to)

monkeys = ARGF.read.split("\n\n").map {|raw|
  raw = raw.lines(chomp: true)
  id = raw.shift.match(/\d+/)[0].to_i
  starting_items = raw.shift.match(/: (.+)/)[1].split(", ").map(&:to_i)
  operation_ = raw.shift.match(/: new = (.+)/)[1]
  operation = ->(old) { eval(operation_) }
  test = raw.shift.match(/\d+/)[0].to_i
  t = raw.shift.match(/\d+/)[0].to_i
  f = raw.shift.match(/\d+/)[0].to_i
  throw_to = ->(n) { (n % test).zero? ? t : f }
  Monkey.new(id, starting_items, operation, test, throw_to)
}

max_worry = monkeys.map(&:test).inject(:*)

inspections = Hash.new(0)
# 20.times do
10_000.times do
  monkeys.each do |monkey|
    until monkey.items.empty?
      inspections[monkey.id] += 1

      item = monkey.items.shift
      item = monkey.operation.(item)
      # item /= 3
      item %= max_worry
      to = monkey.throw_to.(item)
      monkeys[to].items << item
    end
  end
end

p inspections.values.max(2).inject(:*)
