require "set"

Valve = Data.define(:name, :flow_rate, :tunnels)

valves = ARGF.read.scan(/Valve (.+) has flow rate=(\d+); tunnels? leads? to valves? ((?~\n))/)
  .map {|name, flow_rate, tunnels|
    Valve.new(name, flow_rate.to_i, tunnels.split(", "))
  }

Network = Data.define(:valves) do
  def initialize(*)
    @connections = Hash.new {|h,start|
      current = [[start]]
      result = { start => %w[ AA ] }

      until current.empty?
        path = current.shift
        links = valves.fetch(path.last).tunnels
          .reject { result.has_key?(_1) }
          .map { path + [_1] }
        result.merge!(links.to_h { [_1.last, _1] })
        current.concat(links)
      end

      h[start] = result
    }

    super
  end

  def connections(start) = @connections[start]
end

Move = Data.define(:reward, :target, :path) do
  def cost = path.length
end

State = Data.define(:net, :current, :max, :turn, :pressure, :opened) do
  def best_moves
    best_moves = []
    best_state = self

    moves.each do |move|
      next_state = applied(move)
      next_state, next_moves = next_state.best_moves;
      next_moves << move
      if next_state.pressure > best_state.pressure
        best_moves = next_moves
        best_state = next_state
      end
    end

    [best_state, best_moves]
  end

  def applied(move)
    self.class.new(
      net,
      move.target,
      max,
      turn + move.cost,
      pressure + move.reward,
      opened + [move.target],
    )
  end

  def moves
    return enum_for(__method__) unless block_given?

    net
      .connections(current)
      .reject { opened.include?(_1) }
      .each do |name, path|
        flow = net.valves.fetch(name).flow_rate
        reward = flow * (turns_left - path.length)
        if reward.positive?
          yield Move.new(reward, name, path)
        end
      end
  end

  def turns_left = max - turn
end

network = Network.new(valves.to_h { [_1.name, _1] })

state = State.new(network, "AA", 30, 0, 0, [])
best_state, moves = state.best_moves
pp best_state, moves
