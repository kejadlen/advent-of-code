# turns = ARGF.read.scan(/\d+/).map(&:to_i)
# until turns.size == 2020
#   turns << if turns.count(turns.last) == 1
#              0
#            else
#              a, b = turns.filter_map.with_index {|x,i|
#                x == turns.last ? i : nil
#              }[-2,2]
#              b - a
#            end
# end

start = ARGF.read.scan(/\d+/).map(&:to_i)

turns = Hash.new
last = start.pop
start.each.with_index do |x,i|
  turns[x] = i+1
end

(start.size+1...30000000).each do |turn|
  if n = turns[last]
    turns[last] = turn
    last = turn - n
  else
    turns[last] = turn
    last = 0
  end
end

p last
