require "strscan"

def evaluate(input)
  while input.include?(?()
    input = input.gsub(/\((?~[()])+\)/) {|m| evaluate(m[1..-2]) }
  end

  # ss = StringScanner.new(input)
  # n = ss.scan(/\d+/).to_i
  # until ss.eos?
  #   case
  #   when ss.scan(/\s*\+\s*(\d+)/)
  #     n += ss.captures[0].to_i
  #   when ss.scan(/\s*\*\s*(\d+)/)
  #     n *= ss.captures[0].to_i
  #   else
  #     fail
  #   end
  # end
  # n

  while input.include?(?+)
    input = input.gsub(/\d+\s*\+\s*\d+/) {|m| eval(m) }
  end
  while input.include?(?*)
    input = input.gsub(/\d+\s*\*\s*\d+/) {|m| eval(m) }
  end
  input.to_i
end

p ARGF.read.split("\n").map {|line| evaluate(line) }.sum

