#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########

#############
#...........#
###D#D#A#A###
  #C#C#B#B#
  #########

State = Struct.new(:spaces, :energy) do
  ENERGY = { A: 1, B: 10, C: 100, D: 1000 }.transform_keys(&:to_s)
  ROOMS = [2, 4, 6, 8]

  def rooms = ROOMS.to_h { [_1, spaces.fetch(_1)] }

  def valid_moves

  end
end

spaces = Array.new(11) { [] }
# input = "DC DC AB AB"
input = "BA CD BC DA"
input.split(" ").map(&:chars).each.with_index do |amphipods, i|
  spaces[(i+1) * 2] = amphipods
end

start = State.new(spaces, 0)

p start
p start.rooms
p start.valid_moves
