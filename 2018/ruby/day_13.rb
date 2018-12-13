Cart = Struct.new(*%i[ x y dir turns ])
map = ARGF.read.chomp.lines.map(&:chomp).map(&:chars)

carts = []
map.each.with_index {|row,y|
  row.each.with_index {|i,x|
    carts << Cart.new(x, y, i, 0) if %w[ ^ v < > ].include?(i)
  }
}

loop do
  carts.sort_by {|cart|
    [cart.y, cart.x]
  }.each do |cart|
    case cart.dir
    when ?^
      cart.y -= 1
      crashes = carts.select {|candidate| candidate.x == cart.x && candidate.y == cart.y }
      carts.delete_if {|candidate| crashes.include?(candidate) } if crashes.size > 1
      case map[cart.y][cart.x]
      when ?\\
        cart.dir = ?<
      when ?/
        cart.dir = ?>
      when ?+
        case cart.turns % 3
        when 0
          cart.dir = ?<
        when 1
        when 2
          cart.dir = ?>
        end
        cart.turns += 1
      end
    when ?v
      cart.y += 1
      crashes = carts.select {|candidate| candidate.x == cart.x && candidate.y == cart.y }
      carts.delete_if {|candidate| crashes.include?(candidate) } if crashes.size > 1
      case map[cart.y][cart.x]
      when ?\\
        cart.dir = ?>
      when ?/
        cart.dir = ?<
      when ?+
        case cart.turns % 3
        when 0
          cart.dir = ?>
        when 1
        when 2
          cart.dir = ?<
        end
        cart.turns += 1
      end
    when ?<
      cart.x -= 1
      crashes = carts.select {|candidate| candidate.x == cart.x && candidate.y == cart.y }
      carts.delete_if {|candidate| crashes.include?(candidate) } if crashes.size > 1
      case map[cart.y][cart.x]
      when ?\\
        cart.dir = ?^
      when ?/
        cart.dir = ?v
      when ?+
        case cart.turns % 3
        when 0
          cart.dir = ?v
        when 1
        when 2
          cart.dir = ?^
        end
        cart.turns += 1
      end
    when ?>
      cart.x += 1
      crashes = carts.select {|candidate| candidate.x == cart.x && candidate.y == cart.y }
      carts.delete_if {|candidate| crashes.include?(candidate) } if crashes.size > 1
      case map[cart.y][cart.x]
      when ?\\
        cart.dir = ?v
      when ?/
        cart.dir = ?^
      when ?+
        case cart.turns % 3
        when 0
          cart.dir = ?^
        when 1
        when 2
          cart.dir = ?v
        end
        cart.turns += 1
      end
    end

    # puts map.map.with_index {|row,y|
    #   row.map.with_index {|i,x|
    #     cart = carts.find {|cart| cart.x == x && cart.y == y }
    #     cart ? cart.dir : i
    #   }.join
    # }.join("\n")
    # puts

    # crashes = Hash.new(0)
    # carts.each {|cart| crashes[[cart.x, cart.y]] += 1 }
    # crashes = crashes.select {|_,v| v > 1 }.map(&:first)
    # crashes.each do |(x,y)|
    #   p x
    #   p y
    #   carts.delete_if {|cart| cart.x == x && cart.y == y }
    # end
    # if crashes.values.any? {|v| v > 1 }
    #   p crashes.find {|_,v| v > 1 }
    #   exit
    # end
  end

  if carts.size == 1
    p carts
    exit
  end

  # p carts
  # sleep 1
end
