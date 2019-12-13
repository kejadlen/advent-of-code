# typed: ignore

require "stringio"

require_relative "computer"

class Game
  def initialize
    @output = Hash.new(0)
    @min_x, @max_x, @min_y, @max_y = 0, 0, 0, 0
  end

  def []=(x, y, value)
    @output[[x, y]] = value

    @min_x = [@min_x, x].min
    @max_x = [@max_x, x].max
    @min_y = [@min_y, y].min
    @max_y = [@max_y, y].max
  end

  def ball_pos
    @output.key(4)
  end

  def paddle_pos
    @output.key(3)
  end

  def score
    @output[[-1, 0]]
  end

  def to_s
    min_x = [0, @min_x].max

    screen = (@min_y..@max_y).map {|y|
      (min_x..@max_x).map {|x|
        tile(@output[[x, y]])
      }.join
    }.join("\n")

    score = @output[[-1, 0]] || 0

    "#{screen}\n#{score}"
  end

  private

  def tile(id)
    case id
    when 0 then " "
    when 1 then ?█
    when 2 then ?▒
    when 3 then ?▄
    when 4 then ?@
    else fail "unexpected tile id: #{id}"
    end
  end
end

class FollowBall
  def initialize(game)
    @game = game
    @last_ball = nil
  end

  def gets
    ball, paddle = nil, nil
    until [ball, paddle].none?(&:nil?) && ball != @last_ball
      ball = @game.ball_pos
      paddle = @game.paddle_pos
    end
    @last_ball = ball

    # puts @game

    # STDIN.gets
    ball[0] <=> paddle[0]
  end
end

game = Game.new
follow_ball = FollowBall.new(game)
output, output_writer = IO.pipe

Thread.new do
  loop do
    x, y, tile_id = 3.times.map { output.gets.to_i }
    game[x, y] = tile_id
  end
end

Thread.new do
  program = File.read("day_13.txt").split(?,).map(&:to_i)
  program[0] = 2

  Computer.new(program).run(follow_ball, output_writer)

  sleep 1

  puts game.score
end.join
