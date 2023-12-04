cards = ARGF.read.scan(/Card\s+(\d+):+((?~\|))\|(.*)/)
  .to_h {|id, *v|
    [id.to_i, v.map { _1.scan(/\d+/).map(&:to_i) }]
  }

# part one
p cards.values
  .map {|winning,card|
    winners = (card & winning)
    winners.empty? ? 0 : 2 ** (winners.length - 1)
  }
  .sum

# part two
wins = Hash.new {|h,k|
  winning, card = cards.fetch(k)
  winners = winning & card
  new_cards = (1..winners.length).map { k + _1 }

  h[k] = winners.empty? ? 1 : 1 + new_cards.sum { h[_1] }
}
p cards.map {|id,(winning,card)|
    wins[id]
  }
  .sum
