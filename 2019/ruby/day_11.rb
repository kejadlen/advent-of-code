# typed: ignore

require "stringio"

require_relative "computer"

include Math

panels = Hash.new {|h,k| h[k] = [0]}
panels[[0, 0]] = [1]

i_r, i_w = IO.pipe
o_r, o_w = IO.pipe

Robot = Struct.new(:panel, :rad)

robot = Robot.new([0, 0], PI/2)

t = Thread.new {
  loop do
    i_w.puts(panels[robot.panel].last)

    panels[robot.panel] << o_r.gets.to_i
    dir = o_r.gets.to_i
    raise "unexpected direction: #{dir}" unless [0, 1].include?(dir)

    robot.rad += -(2*dir - 1) * (PI/2)

    delta = [cos(robot.rad).to_i, sin(robot.rad).to_i]
    robot.panel = robot.panel.zip(delta).map(&:sum)
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
