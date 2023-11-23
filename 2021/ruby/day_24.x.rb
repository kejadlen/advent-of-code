def run(input)
  w, x, y, z = 0, 0, 0, 0

  # w = input.shift
  # x = z % 26
  # z = (z / 1.to_f).floor
  # x += 13
  # x = x == w ? 0 : 1
  # y = 25 * x + 1 # either y = 26 or y = 1
  # z *= y # 0
  # # p [w, x, y, z]

  # y = (w + 13) * x
  # z += y
  # # p [w, x, y, z]
  # # puts

  # w = input.shift
  # x = z % 26
  # z = (z / 1.to_f).floor
  # x += 11
  # x = x == w ? 0 : 1
  # y = 25 * x + 1
  # z *= y
  # # p [w, x, y, z]

  # y = (w + 10) * x
  # z += y
  # # p [w, x, y, z]
  # # puts

  # w = input.shift
  # x = z % 26
  # z = (z / 1.to_f).floor
  # x += 15
  # x = x == w ? 0 : 1
  # y = (25 * x) + 1
  # z *= y
  # # p [w, x, y, z]

  # y = (w + 5) * x
  # z += y
  # # p [w, x, y, z]
  # # puts

  # w = input.shift
  # x = z % 26
  # z = (z / 26.to_f).floor
  # x += -11
  # x = x == w ? 0 : 1
  # y = (25 * x) + 1
  # z *= y
  # # p [w, x, y, z]

  # y = (w + 14) * x
  # z += y
  # # p [w, x, y, z]
  # # puts

  # return [w, x, y, z]

  # w = input.shift
  # x = z % 26
  # z = (z / 1.to_f).floor
  # x += 14
  # x = x == w ? 0 : 1
  # y = 25 * x + 1
  # z *= y
  # # p [w, x, y, z]

  # y = (w + 5) * x
  # z += y
  # # p [w, x, y, z]
  # # puts
  # # puts

  # w = input.shift
  # x = z % 26
  # z = (z / 26.to_f).floor
  # x += 0
  # x = x == w ? 0 : 1
  # y = 25 * x + 1
  # z *= y
  # # p [w, x, y, z]

  # y = (w + 15) * x
  # z += y
  # # p [w, x, y, z]
  # # puts

  # return [w, x, y, z]

  # w = input.shift
  # x = z % 26
  # z = (z / 1.to_f).floor
  # x += 12
  # x = x == w ? 0 : 1
  # y = 25 * x + 1
  # z *= y
  # # p [w, x, y, z]

  # y *= 0
  # y += w
  # y += 4
  # y *= x
  # z += y
  # # p [w, x, y, z]

  # w = input.shift
  # x *= 0
  # x += z
  # x %= 26
  # z = (z / 1.to_f).floor
  # x += 12
  # x = x == w ? 1 : 0
  # x = x == 0 ? 1 : 0
  # y *= 0
  # y += 25
  # y *= x
  # y += 1
  # z *= y
  # # p [w, x, y, z]

  # y *= 0
  # y += w
  # y += 11
  # y *= x
  # z += y
  # # p [w, x, y, z]

  # w = input.shift
  # x *= 0
  # x += z
  # x %= 26
  # z = (z / 1.to_f).floor
  # x += 14
  # x = x == w ? 1 : 0
  # x = x == 0 ? 1 : 0
  # y *= 0
  # y += 25
  # y *= x
  # y += 1
  # z *= y
  # # p [w, x, y, z]

  # y *= 0
  # y += w
  # y += 1
  # y *= x
  # z += y
  # # p [w, x, y, z]
  # # puts
  # # puts

  # w = input.shift
  # x *= 0
  # x += z
  # x %= 26
  # z = (z / 26.to_f).floor
  # x += -6
  # x = x == w ? 1 : 0
  # x = x == 0 ? 1 : 0
  # y *= 0
  # y += 25
  # y *= x
  # y += 1
  # z *= y
  # # p [w, x, y, z]

  # y *= 0
  # y += w
  # y += 15
  # y *= x
  # z += y
  # # p [w, x, y, z]

  # return [w, x, y, z]

  # w = input.shift
  # x *= 0
  # x += z
  # x %= 26
  # z = (z / 26.to_f).floor
  # x += -10
  # x = x == w ? 1 : 0
  # x = x == 0 ? 1 : 0
  # y *= 0
  # y += 25
  # y *= x
  # y += 1
  # z *= y
  # # p [w, x, y, z]

  # y *= 0
  # y += w
  # y += 12
  # y *= x
  # z += y
  # # p [w, x, y, z]

  # return [w, x, y, z]

  w = input.shift
  x *= 0
  x += z
  x %= 26
  z = (z / 26.to_f).floor
  x += -12
  x = x == w ? 1 : 0
  x = x == 0 ? 1 : 0
  y *= 0
  y += 25
  y *= x
  y += 1
  z *= y
  # p [w, x, y, z]

  y *= 0
  y += w
  y += 8
  y *= x
  z += y
  # p [w, x, y, z]

  return [w, x, y, z]

  w = input.shift
  x = z % 26
  z = (z / 26.to_f).floor
  x += -3
  x = x == w ? 0 : 1
  y = 25 * x + 1
  z *= y
  # p [w, x, y, z]

  y = (w + 14) * x
  z += y
  # p [w, x, y, z]

  w = input.shift
  x = z % 26              # z - 5 must be w
  z = (z / 26.to_f).floor # z must be < 26
  x += -5                 # w must be x - 5
  x = x == w ? 0 : 1      # x must be w
  y = 25 * x + 1
  z *= y                  # z must be 0
  # p [w, x, y, z]

  y = (w + 9) * x         # x must be 0
  z += y                  # y must be 0

  [w, x, y, z]
end

# 99999999999999.downto(11111111111111).lazy.map(&:to_s).reject { _1.include?(?0) }.each do |input|
  vars = run(input.chars.map(&:to_i))
  p [input, vars[3]] if vars[3] < 400
  if vars[3].zero?
    puts input
    exit
  end
end
