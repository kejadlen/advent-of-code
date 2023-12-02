input = ARGF.read

def cubes(input)
  input
    .scan(/(\d+) (\w+)/)
    .to_h(&:reverse)
    .transform_values(&:to_i)
end

bag = cubes("12 red cubes, 13 green cubes, and 14 blue cubes")

Game = Data.define(:id, :reveals) do
  def possible?(bag)
    reveals.all? {|reveal|
      bag.all? {|color, n| n >= reveal.fetch(color, 0) }
    }
  end
end

games = input
  .scan(/^Game (\d+): ((?~\n))/)
  .map {|id, reveals|
    Game.new(
      id.to_i,
      reveals.split(?;).map { cubes(_1) }
    )
  }

# part one
p games.select { _1.possible?(bag) }.sum(&:id)

# part two
p games
  .map {|game|
    game.reveals.inject {|bag, reveal|
      bag.merge(reveal) { [_2, _3].max }
    }
  }
  .sum {|bag| bag.values.inject(:*) }
