actions = ARGF.read.scan(/(\w)(\d+)/).map {|a,v| [a, v.to_i] }

dir = 0
pos = [0, 0]
way = [10, 1]
actions.each do |a,v|
  # delta = case a
  #         when ?N
  #           [ 0,  v]
  #         when ?S
  #           [ 0, -v]
  #         when ?E
  #           [ v,  0]
  #         when ?W
  #           [-v,  0]
  #         when ?L
  #           dir += v
  #           [0, 0]
  #         when ?R
  #           dir -= v
  #           [0, 0]
  #         when ?F
  #           rad = dir * Math::PI / 180.0
  #           [v * Math.cos(rad), v * Math.sin(rad)].map(&:round)
  #         else
  #           fail
  #         end
  case a
  when ?N
    way[1] += v
  when ?S
    way[1] -= v
  when ?E
    way[0] += v
  when ?W
    way[0] -= v
  when ?L
    rad = Math.atan2(*way.reverse)
    dis = Math.sqrt(way.map {|x| x**2 }.sum)
    rad += v * Math::PI / 180
    way = [dis * Math.cos(rad), dis * Math.sin(rad)].map(&:round)
  when ?R
    rad = Math.atan2(*way.reverse)
    dis = Math.sqrt(way.map {|x| x**2 }.sum)
    rad -= v * Math::PI / 180
    way = [dis * Math.cos(rad), dis * Math.sin(rad)].map(&:round)
  when ?F
    delta = way.map {|i| v * i }
    pos = pos.zip(delta).map {|a,b| a + b }
  else
    fail
  end
end
p pos.map(&:abs).sum
