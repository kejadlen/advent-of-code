def fire(v, target)
  return enum_for(__method__, v, target) unless block_given?

  pos = [0,0]
  v_x, v_y = v

  loop do
    yield pos

    return if target.zip(pos).all? { _1.cover?(_2) }

    pos = pos.zip([v_x, v_y]).map { _1.sum }
    v_x -= 1 if v_x > 0
    v_y -= 1

    return if pos[0] > target[0].end
    return if pos[1] < target[1].begin
  end
end

input = ARGF.read.scan(/x=(.+), y=(.+)/)
target = input[0].map { eval(_1) }

xs = (0..target[0].end).select { (1.._1).sum > target[0].begin }
haystack = xs.flat_map {|x| (-256..256).map {|y| [x, y] }}
haystack.select! {|v| fire(v, target).each.any? {|pos| target.zip(pos).all? { _1.cover?(_2) }}}

# p haystack.map {|v| fire(v, target).each.map { _2 }.max }.max
p haystack.count
