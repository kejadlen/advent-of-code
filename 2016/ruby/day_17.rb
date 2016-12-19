require 'digest/md5'

State = Struct.new(:location, :path)

Maze = Struct.new(:passcode, :size) do
  def walk
    return enum_for(__method__) unless block_given?

    states = [State.new([0,0], '')]
    until states.empty?
      state = states.shift
      yield state

      next if state.location == [3,3]

      hash = Digest::MD5.hexdigest("#{passcode}#{state.path}")[0,4]
      open_doors = %i[ U D L R ].select.with_index {|_, index|
        'bcdef'.include?(hash[index])
      }

      {
        U: [ 0, -1],
        D: [ 0,  1],
        L: [-1,  0],
        R: [ 1,  0],
      }.select {|door, _|
        open_doors.include?(door)
      }.map {|door, (dx, dy)|
        x = state.location[0] + dx
        y = state.location[1] + dy

        location = [x, y]
        path = state.path + door.to_s
        State.new(location, path)
      }.select {|state|
        state.location.all? {|i| (0...size).cover?(i) }
      }.each do |state|
        states << state
      end
    end
  end
end

p Maze.new('yjjvjgan', 4).walk.select {|state|
  state.location == [3, 3]
}.map(&:path).map(&:length).max
