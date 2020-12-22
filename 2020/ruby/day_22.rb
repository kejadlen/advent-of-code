require "set"

decks = ARGF.read.split("\n\n").map {|players| players.split("\n")[1..].map(&:to_i) }

# part one

# until decks.any?(&:empty?)
#   p decks
#   top_cards = decks.map(&:shift)
#   fail if top_cards.tally.size == 1

#   if top_cards.first > top_cards.last
#     decks.first.concat(top_cards)
#   else
#     decks.last.concat(top_cards.reverse)
#   end
# end

SEEN = Set.new
def recursive_combat!(decks)
  until decks.any?(&:empty?)
    return 0 if SEEN.include?(decks)
    SEEN << decks

    top_cards = decks.map(&:shift)
    winner = if decks.zip(top_cards).all? {|d,tc| d.size >= tc }
               recursive_combat!(decks.zip(top_cards).map {|d,tc| d[0,tc] })
             elsif top_cards.first > top_cards.last
               0
             else
               1
             end

    if winner == 0
      decks.first.concat(top_cards)
    else
      decks.last.concat(top_cards.reverse)
    end
  end

  decks.index {|d| !d.empty? }
end

recursive_combat!(decks)

p decks.flatten.reverse.map.with_index {|v,i| v * (i+1) }.sum
