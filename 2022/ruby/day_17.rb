require "set"

rocks = <<~ROCKS.split("\n\n")
  ####

  .#.
  ###
  .#.

  ..#
  ..#
  ###

  #
  #
  #
  #

  ##
  ##
ROCKS
rocks = rocks
  .map {|rock| rock.lines(chomp: true).reverse.map(&:chars) }
  .map {|rock|
    rock.each.with_index.with_object(Set.new) {|(row, y), rocks|
      row.each.with_index do |c, x|
        rocks << [x, y] if c == ?#
      end
    }
  }
rocks = rocks.cycle

jet_pattern = ARGF.read.strip.chars
jet_pattern = jet_pattern.cycle

chamber = Hash.new {|_,(x,y)| !(0...7).cover?(x) || y.negative? }

def move_rock(chamber, rock, dx, dy)
  next_rock = rock.map {|x,y| [x+dx, y+dy] }

  if next_rock.any? {|x,y| chamber[[x, y]] }
    rock
  else
    next_rock
  end
end

def debug(chamber, rock)
  max_y = [chamber.keys.map(&:last).max || 0, rock.map(&:last).max || 0].max

  puts
  puts max_y.downto(0).map {|y|
    (0...7).map {|x|
      (chamber[[x,y]] || rock.include?([x,y])) ? ?# : ?.
    }.join
  }.join("\n")
end

2022.times do
  rock = rocks.next

  y = chamber.empty? ? 3 : chamber.keys.map(&:last).max + 4
  x = 2
  rock = move_rock(chamber, rock, x, y)

  loop do
    rock = case jet = jet_pattern.next
           when ?< then move_rock(chamber, rock, -1, 0)
           when ?> then move_rock(chamber, rock,  1, 0)
           else fail "invalid jet pattern: #{jet}"
           end

    next_rock = move_rock(chamber, rock, 0, -1)
    break if rock == next_rock
    rock = next_rock
  end

  chamber.merge!(rock.to_h { [_1, true] })
end

# debug(chamber, Set.new)
max_y = chamber.keys.map(&:last).max + 1
p max_y

candidates = (0..max_y).select {|y| (0...7).count {|x| chamber[[x,y]] } == 6 }
# max_delta = candidates.each_cons(2).map { _2 - _1 }.max
candidates.
p candidates
p max_delta
