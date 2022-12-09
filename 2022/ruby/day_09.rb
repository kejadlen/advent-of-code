require "set"

motions = ARGF.read.scan(/([RLUD])\s+(\d+)/).map { [_1, _2.to_i] }

class Snake
  attr_reader :tail

  def initialize
    @head, @tail = [0, 0], [0, 0]
  end

  def move!(dir)
    delta = case dir
            when ?L then [ 0, -1]
            when ?U then [ 1,  0]
            when ?R then [ 0,  1]
            when ?D then [-1,  0]
            else fail dir.inspect
            end
    @head = @head.zip(delta).map { _1 + _2 }

    delta = @head.zip(@tail).map { _1 - _2 }
    if delta.any? { _1.abs > 1 }
      if delta.any?(&:zero?)
        @tail = @tail.zip(delta.map { _1.clamp(-1, 1) }).map { _1 + _2 }
      else
        @tail = @tail.zip(delta.map { _1.clamp(-1, 1) }).map { _1 + _2 }
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
