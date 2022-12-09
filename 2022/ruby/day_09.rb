require "set"

motions = ARGF.read.scan(/([RLUD])\s+(\d+)/).map { [_1, _2.to_i] }

class Snake
  def initialize
    @knots = Array.new(10) { [0, 0] }
  end

  def tail = @knots.last

  def move!(dir)
    delta = case dir
            when ?L then [ 0, -1]
            when ?U then [ 1,  0]
            when ?R then [ 0,  1]
            when ?D then [-1,  0]
            else fail dir.inspect
            end
    @knots[0] = @knots[0].zip(delta).map { _1 + _2 }

    @knots = @knots[1..].inject([@knots[0]]) {|knots, tail|
      head = knots.last
      delta = head.zip(tail).map { _1 - _2 }
      knots << if delta.any? { _1.abs > 1 }
                 tail.zip(delta.map { _1.clamp(-1, 1) }).map { _1 + _2 }
               else
                 tail
               end
    }
  end
end

snake = Snake.new
seen = Set.new

motions.each do |dir, distance|
  distance.times do
    snake.move!(dir)
    seen << snake.tail
  end
end

p seen.size
