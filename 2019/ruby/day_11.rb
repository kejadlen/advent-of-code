require "stringio"

require_relative "computer"

panels = Hash.new {|h,k| h[k] = [0]}
panels[[0, 0]] = [1]

i_r, i_w = IO.pipe
o_r, o_w = IO.pipe

Robot = Struct.new(:panel, :dir)

dirs = %i[ up right down left ]
robot = Robot.new([0, 0], 0)

t = Thread.new {
  loop do
    i_w.puts(panels[robot.panel].last)

    panels[robot.panel] << o_r.gets.to_i
    dir = o_r.gets.to_i

    delta = case dir
            when 0 then -1
            when 1 then 1
            else raise "unexpected direction: #{dir}"
            end
    robot.dir += delta
    robot.dir %= dirs.size
    dir = dirs.fetch(robot.dir)

    delta = case dir
            when :up    then [ 0,  1]
            when :right then [ 1,  0]
            when :down  then [ 0, -1]
            when :left  then [-1,  0]
            end
    robot.panel = robot.panel.zip(delta).map {|a,b| a + b }
  end
}

Thread.new { Computer.from(ARGF.read).run(i_r, o_w) }.join

# p panels.values.count {|v| v.size > 1 }

min_x, max_x = panels.keys.map(&:first).minmax
min_y, max_y = panels.keys.map(&:last).minmax

letters = (min_y..max_y).map {|y|
  (min_x..max_x).map {|x|
    (panels[[x, y]].last == 1) ? ?█ : " "
  }.join
}.reverse.join("\n")

puts letters
