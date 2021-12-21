# Player = Struct.new(:space, :score)
# one = Player.new(7, 0)
# two = Player.new(3, 0)

# class Die
#   def initialize
#     @value = 0
#     @rolls = 0
#   end

#   attr_reader :rolls

#   def roll
#     value = @value

#     @value += 1
#     @value %= 100

#     @rolls += 1

#     value
#   end
# end
# die = Die.new

# loop do
#   one.space += 3.times.sum { die.roll + 1 }
#   one.space %= 10
#   one.score += one.space + 1
#   break if one.score >= 1000

#   two.space += 3.times.sum { die.roll + 1 }
#   two.space %= 10
#   two.score += two.space + 1
#   break if two.score >= 1000
# end

# p [one, two].map(&:score).min * die.rolls

ROLLS = (1..3).flat_map {|a| (1..3).flat_map {|b| (1..3).map {|c|
  [a, b, c].sum
}}}.tally
Player = Struct.new(:score, :space, keyword_init: true)
wins = Hash.new {|h,k|
  one, two = k

  multiverse = ROLLS.map {|delta,n|
    space = (one.space + delta) % 10
    [Player.new(score: one.score + space + 1, space: space), n]
  }
  one_wins, one_ongoing = multiverse.partition {|player,_| player.score >= 21 }
  one_wins = one_wins.sum(&:last)

  multiverse = ROLLS.map {|delta,n|
    space = (two.space + delta) % 10
    [Player.new(score: two.score + space + 1, space: space), n]
  }

  wins = one_ongoing.flat_map {|one, n_one| multiverse.map {|two, n_two|
    n = n_one * n_two
    if two.score >= 21
      { one: 0, two: n }
    else
      h[[one, two]].map { [_1, _2 * n] }.to_h
    end
  }}
  wins = wins.inject({one: 0, two: 0}) {|acc,wins| acc.merge(wins) { _2 + _3 }}

  h[k] = {
    one: one_wins + wins.fetch(:one),
    two: wins.fetch(:two),
  }
}

# p wins[[Player.new(score: 0, space: 3), Player.new(score: 0, space: 7)]]
p wins[[Player.new(score: 0, space: 7), Player.new(score: 0, space: 3)]].values.max
