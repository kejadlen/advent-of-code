input = ARGF.read
numbers, *cards = input.split("\n\n")
numbers = numbers.split(?,).map(&:to_i)
cards = cards.map {|c| c.split("\n").map {|r| r.split(/\s+/).reject(&:empty?).map(&:to_i) }}

def win?(card, drawn)
  return true if card.any? {|row| row.all? {|c| drawn.include?(c) }}
  return true if card.transpose.any? {|col| col.all? {|c| drawn.include?(c) }}
  # return true if (0..4).all? {|x| drawn.include?(card.fetch(x).fetch(x)) }
  # return true if (0..4).all? {|x| drawn.include?(card.fetch(x).fetch(4-x)) }
  return false
end

(0..numbers.length).each do |i|
  drawn = numbers[0..i]

  # winning_card = cards.find {|c| win?(c, drawn) }
  # if winning_card
  #   p winning_card.flatten.reject {|x| drawn.include?(x) }.sum * drawn.last
  #   exit
  # end

  if cards.length == 1 && winning_card = cards.find {|c| win?(c, drawn) }
    p winning_card.flatten.reject {|x| drawn.include?(x) }.sum * drawn.last
    exit
  else
    cards = cards.reject {|c| win?(c, drawn) }
  end
end
