require "bundler/setup"
require "minitest/autorun"

require "parslet"

Monkey = Struct.new(:id, :items, :operation, :test, :t, :f) do
  def throw_to(item)
    (item % test).zero? ? t : f
  end
end

class MonkeyParser < Parslet::Parser
  rule(:num) { match("[0-9]").repeat.as(:num) }
  rule(:space) { match("\\s").repeat }
  rule(:newline) { str("\n") }

  rule(:monkey) {
    space >> str("Monkey ") >> num.as(:id) >> str(":") >>
    space >> str("Starting items: ") >> ( num >> ( str(", ") >> num ).repeat ).as(:items) >>
    space >> str("Operation: new = ") >> (newline.absent? >> any).repeat.as(:op) >>
    space >> str("Test: divisible by ") >> num.as(:test) >>
    space >> str("If true: throw to monkey ") >> num.as(:true) >>
    space >> str("If false: throw to monkey ") >> num.as(:false) >>
    space
  }

  rule(:monkeys) { monkey.repeat }

  root(:monkeys)
end

class MonkeyTransform < Parslet::Transform
  rule(num: simple(:x)) { x.to_i }

  rule(
    id: simple(:id),
    items: sequence(:items),
    op: simple(:op),
    test: simple(:test),
    true: simple(:t),
    false: simple(:f),
  ) {
    Monkey.new(id, items, op, test, t, f)
  }
end

class TestDay11 < Minitest::Test
  def test_day_11
    tree = MonkeyParser.new.parse(<<~MONKEY)
      Monkey 0:
        Starting items: 79, 98
        Operation: new = old * 19
        Test: divisible by 23
          If true: throw to monkey 2
          If false: throw to monkey 3
    MONKEY

    monkeys = MonkeyTransform.new.apply(tree)
    assert_equal [Monkey.new(0, [79, 98], "old * 19", 23, 2, 3)], monkeys
  end
end
