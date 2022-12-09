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

    (0...@knots.size-1).each do |i|
      head = @knots[i]
      tail = @knots[i+1]

      delta = head.zip(tail).map { _1 - _2 }
      if delta.any? { _1.abs > 1 }
        @knots[i+1] = tail.zip(delta.map { _1.clamp(-1, 1) }).map { _1 + _2 }
      end
    end
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
