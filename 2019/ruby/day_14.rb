reactions = ARGF.read.strip.lines.each.with_object({}) {|line, h|
  reactands = line.scan(/(\d+) (\w+)/).map {|q,c| [c,q.to_i] }
  c, q = reactands.pop
  h[c] = { quantity: q, inputs: reactands }
}.to_h

Factory = Struct.new(:reactions, :supply, :ores_used) do
  def produce(chemical)
    self.ores_used ||= 0

    case reaction = reactions[chemical]
    in { quantity: quantity, inputs: inputs }
    until inputs.all? {|c,q| supply[c] >= q }
        inputs
          .select {|c,q| supply[c] < q }
          .each do |c,_|
            produce(c)
          end
      end

      inputs.each do |c,q|
        self.ores_used += q if c == "ORE"
        supply[c] -= q
      end

      supply[chemical] += quantity
    else
      fail "unexpected reaction: #{reaction}"
    end
  end
end

supply = Hash.new(0)
supply["ORE"] = Float::INFINITY

factory = Factory.new(reactions, supply)
factory.produce("FUEL")
