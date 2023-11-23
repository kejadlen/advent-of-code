INSTRUCTIONS = ARGF.read.split("\n").map { _1.split(/\s+/) }

# INSTRUCTIONS.each do |instruction, *args|
#   a, b = *args
#   case instruction
#   when "inp"
#     puts "#{a} = input.shift"
#   when "add"
#     puts "#{a} += #{b}"
#   when "mul"
#     puts "#{a} *= #{b}"
#   when "div"
#     puts "#{a} = (#{a} / #{b}.to_f).floor"
#   when "mod"
#     puts "#{a} %= #{b}"
#   when "eql"
#     puts "#{a} = #{a} == #{b} ? 1 : 0"
#   else
#     fail
#   end
# end
# exit

VARS = %w[ w x y z ]
def run(input)
  vars = Hash.new(0)

  INSTRUCTIONS.each do |instruction, *args|
    a, b = *args
    b = VARS.include?(b) ? vars[b] : b.to_i
    case instruction
    when "inp"
      vars[a] = input.shift
    when "add"
      vars[a] += b
    when "mul"
      vars[a] *= b
    when "div"
      vars[a] = (vars[a] / b.to_f).floor
    when "mod"
      vars[a] %= b
    when "eql"
      vars[a] = vars[a] == b ? 1 : 0
    else
      fail
    end
  end

  vars
end

99999999999999.downto(11111111111111).lazy.map(&:to_s).reject { _1.include?(?0) }.each do |input|
  vars = run(input.chars.map(&:to_i))
  if vars[?z].zero?
    puts input
    exit
  end
end
