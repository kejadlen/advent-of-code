claims, fabric = ARGF
  .read
  .lines
  .map(&:chomp)
  .reject(&:empty?)
  .each
  .with_object([[], Hash.new {|h,k| h[k] = []}]) { |line, (claims, fabric)|
    line =~ /^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/
    claim = $1.to_i
    x = $2.to_i
    y = $3.to_i
    width = $4.to_i
    height = $5.to_i

    claims << claim
    width.times {|dx|
      height.times {|dy|
        fabric[[y+dy, x+dx]] << claim
      }
    }
  }

p claims.reject {|claim|
  fabric.any? {|_,v|
    v.length > 1 && v.include?(claim)
  }
}
