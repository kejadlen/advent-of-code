# h = 0
# d = 0
# ARGF.read.split("\n").map(&:split).each do |dir, n|
#   n = n.to_i
#   case dir
#   when "forward"
#     h += n
#   when "down"
#     d += n
#   when "up"
#     d -= n
#   else
#     fail dir
#   end
# end
# p h, d, h*d

h = 0
d = 0
aim = 0
ARGF.read.split("\n").map(&:split).each do |dir, n|
  n = n.to_i
  case dir
  when "forward"
    h += n
    d += aim * n
  when "down"
    aim += n
  when "up"
    aim -= n
  else
    fail dir
  end
end
p h, d, h*d
