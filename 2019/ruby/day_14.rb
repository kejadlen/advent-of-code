reactions = ARGF.read.lines.map {|line|
  input, output = line.split(" => ")
  inputs = input.split(", ").map(&:split).each.with_object({}) {|(q,c),h| h[c] = q.to_i }
  q, c = output.split
  [c, { quantity: q.to_i, inputs: inputs }]
}.to_h

class Factory
  attr_reader :ore_consumed

  def initialize(reactions)
    @reactions = reactions
    @supply = Hash.new(0)
    @supply["ORE"] = Float::INFINITY
    @ore_consumed = 0
  end

  def produce(want)
    case @reactions.fetch(want)
    in { quantity: quantity, inputs: inputs }
      until inputs.all? {|c,q| @supply[c] >= q }
        inputs
          .select {|c,q| @supply[c] < q }
          .each do |c,q|
            produce(c)
          end
      end

      inputs.each do |c,q|
        @supply[c] -= q
      end

      @ore_consumed += inputs.fetch("ORE") { 0 }
      @supply[want] += quantity
    end
  end
end

factory = Factory.new(reactions)
factory.produce("FUEL")
puts factory.ore_consumed
