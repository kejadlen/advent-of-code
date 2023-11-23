require "strscan"

include Math

map, path = ARGF.read.chomp.split("\n\n")

map = map.split("\n").each.with_index.with_object({}) {|(row,y),map|
  row.chars.each.with_index do |tile,x|
    map[[y,x]] = tile if tile != " "
  end
}
max_y = map.keys.map(&:first).max
max_x = map.keys.map(&:last).max

start_x = map.keys.select { _1.first.zero? }.map(&:last).min

current = [0, start_x]
facing = 0

ss = StringScanner.new(path)
until ss.eos?
  case
  when n = ss.scan(/\d+/)
    n = n.to_i
    n.times do
      y, x = current.zip([-sin(facing),cos(facing)]).map { _1 + _2 }.map(&:to_i)
      next_tile = map[[y,x]]

      unless next_tile
        puts
        p [y,x, facing]
        y, x = case facing
               when 0      then [y, 0]
               when PI/2   then [max_y, x]
               when PI     then [y, max_x]
               when 3*PI/2 then [0, x]
               else        fail "unexpected facing: #{facing}"
               end
        next_tile = map[[y,x]]
        while next_tile.nil?
          y, x = [y, x].zip([-sin(facing),cos(facing)]).map { _1 + _2 }.map(&:to_i)
          next_tile = map[[y,x]]
        end

        p [y,x,next_tile]
      end

      case next_tile
      when ?.
        current = [y,x]
      when ?#
        break
      else
        fail "unexpected tile: #{next_tile}"
      end
    end
  when dir = ss.scan(/R|L/)
    facing += case dir
              when ?R then -PI/2
              when ?L then  PI/2
              else          fail "unexpected dir: #{dir}"
              end
    facing %= 2*PI
  else
    fail ss.rest
  end
end

row, col = current.map { _1 + 1 }
facing = case facing
         when 0      then 0
         when PI/2   then 3
         when PI     then 2
         when 3*PI/2 then 2
         else
           fail "unexpected facing: #{facing}"
         end
p [1000, 4, 1].zip([row, col, facing]).sum { _1 * _2 }
