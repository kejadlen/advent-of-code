CurrentNumber = Data.define(:coords, :acc)

cur_num = nil
nums = {}
syms = {}
ARGF.readlines(chomp: true).each.with_index do |row, y|
  row.chars.each.with_index do |c, x|
    case c
    when /\d/
      if cur_num
        cur_num.coords << [y,x]
        cur_num.acc << c
      else
        cur_num = CurrentNumber.new([[y,x]], c)
      end
    else
      if cur_num
        nums.merge!(cur_num.coords.to_h { [_1, cur_num.acc.to_i] })
        cur_num = nil
      end

      if c != ?.
        syms[[y,x]] = c
      end
    end
  end

  if cur_num
    nums.merge!(cur_num.coords.to_h { [_1, cur_num.acc.to_i] })
    cur_num = nil
  end
end

# part one
p syms
  .flat_map {|(y,x), _|
    dy = (-1..1).to_a
    dx = (-1..1).to_a
    dy.product(dx)
      .map {|dy,dx| [y+dy,x+dx] }
      .filter_map { nums.fetch(_1, nil) }
      .uniq # lol, hack
  }
  .sum

p syms
  .select { _2 == ?* }
  .filter_map {|(y,x), _|
    dy = (-1..1).to_a
    dx = (-1..1).to_a
    parts = dy.product(dx)
      .map {|dy,dx| [y+dy,x+dx] }
      .filter_map { nums.fetch(_1, nil) }
      .uniq # lol, hack

    if parts.length == 2
      parts
    else
      nil
    end
  }
  .sum { _1.inject(:*) }
