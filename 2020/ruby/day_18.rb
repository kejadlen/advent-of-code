require "strscan"

# def evaluate(input)
#   while input.include?(?()
#     input = input.gsub(/\((?~[()])+\)/) {|m| evaluate(m[1..-2]) }
#   end

#   # part one
#   # ss = StringScanner.new(input)
#   # n = ss.scan(/\d+/).to_i
#   # until ss.eos?
#   #   case
#   #   when ss.scan(/\s*\+\s*(\d+)/)
#   #     n += ss.captures[0].to_i
#   #   when ss.scan(/\s*\*\s*(\d+)/)
#   #     n *= ss.captures[0].to_i
#   #   else
#   #     fail
#   #   end
#   # end
#   # n

#   while input.include?(?+)
#     input = input.gsub(/\d+\s*\+\s*\d+/) {|m| eval(m) }
#   end
#   while input.include?(?*)
#     input = input.gsub(/\d+\s*\*\s*\d+/) {|m| eval(m) }
#   end
#   input.to_i
# end

def evaluate(input)
  stack = [->(x) { x }]

  ss = StringScanner.new(input)
  until ss.eos?
    ss.scan(/\s*/)
    case
    when n = ss.scan(/\d+/)
      stack << stack.pop[n.to_i]
    when ss.scan(/\+/)
      stack << ->(x) { stack.pop + x }
    when ss.scan(/\*/)
      stack << ->(x) { stack.pop * x }
    when ss.scan(/\(/)
      stack << ->(x) { x }
    when ss.scan(/\)/)
      n = stack.pop
      stack << stack.pop[n]
    else
      fail
    end
  end

  stack.pop
end

p ARGF.read.split("\n").map {|line| evaluate(line) }.sum
