Node = Struct.new(*%i[ value next prev ]) do
  def to_s
    out = [value]
    current = self
    loop do
      current = current.next
      break if current == self
      out << current.value
    end
    out.join(" ")
  end
end

ARGF.read.chomp =~ /(\d+) players; last marble is worth (\d+) points/
num_players = $1.to_i
num_marbles = $2.to_i * 100

current = Node.new(0, nil, nil)
current.next = current.prev = current

current_player = 0
scores = Array.new(num_players, 0)

(1...num_marbles).each do |marble|
  if marble % 23 == 0
    scores[current_player] += marble
    7.times { current = current.prev }
    scores[current_player] += current.value
    current.next.prev = current.prev
    current.prev.next = current.next
    current = current.next
  else
    current = current.next
    current.next = Node.new(marble, current.next, current)
    current = current.next
    current.next.prev = current
  end

  # puts "[#{current_player + 1}] #{current}"
  puts marble if marble % 100000 == 0

  current_player = (current_player + 1) % num_players
end

p scores.max
