require "strscan"

input = ARGF.read.strip
input = input.gsub(/!./, "")

p input.scan(/<[^>]*>/).map {|g| g.size - 2 }.sum

input = input.gsub(/<[^>]*>/, "")
  .gsub(?,, "")

ss = StringScanner.new(input)
score = 0
group = 0
until ss.eos?
  case
  when ss.scan(/\{/)
    group += 1
  when ss.scan(/\}/)
    score += group
    group -= 1
  else
    raise "omg!"
  end
end
p score
