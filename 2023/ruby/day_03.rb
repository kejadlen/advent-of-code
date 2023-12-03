cur_num = nil
nums = {}
syms = {}
ARGF.readlines(chomp: true).each.with_index do |row, y|
  row.chars.each.with_index do |c, x|
    case c
    when /\d/
      if cur_num
        cur_num << c
      else
        cur_num = c
      end
    else
      if cur_num
        nums[[y,x-cur_num.length]] = cur_num.to_i
        cur_num = nil
      end

      if c != ?.
        syms[[y,x]] = c
      end
    end
  end

  if cur_num
    nums[[y, row.length-cur_num.length]] = cur_num.to_i
    cur_num = nil
  end
end

p nums
  .filter_map {|(y,x), num|
    dy = (-1..1).to_a
    dx = (-1..num.digits.length).to_a
    if dy.product(dx)
        .map {|dy,dx| [y+dy,x+dx] }
        .any? { syms.has_key?(_1) }
      num
    else
      nil
    end
  }
  .sum
