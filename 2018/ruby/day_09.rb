ARGF.read.chomp =~ /(\d+) players; last marble is worth (\d+) points/
num_players = $1.to_i
num_marbles = $2.to_i

circle = []
marbles = (0...num_marbles).to_a

zero = marbles.shift
circle << zero

current_marble_index = 0
current_player = 0
scores = Hash.new(0)

until marbles.empty?
  current_marble = marbles.shift

  if current_marble % 23 == 0
    scores[current_player] += current_marble
    index = (current_marble_index - 7) % circle.size
    scores[current_player] += circle.delete_at(index)
    current_marble_index = index
  else
    index = (current_marble_index + 2) % circle.size - 1
    index += 1 unless index == -1
    circle.insert(index, current_marble)
    current_marble_index = index % circle.size
  end

  # puts "[#{current_player + 1}] #{circle.join(" ")}"

  current_player = (current_player + 1) % num_players
end

p scores.max_by(&:last)
