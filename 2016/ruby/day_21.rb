INSTRUCTIONS = ARGF.read.split("\n")

def scramble(input)
  INSTRUCTIONS.each do |instruction|
    case instruction
    when /swap position (\d+) with position (\d+)/
      x = $1.to_i
      y = $2.to_i
      input[x], input[y] = input[y], input[x]
    when /swap letter (\w+) with letter (\w+)/
      x = $1
      y = $2
      input.tr!("#{x}#{y}", "#{y}#{x}")
    when /rotate (left|right) (\d+) steps?/
      steps = $2.to_i
      steps = -steps if $1 == 'right'
      input = input.chars.rotate(steps).join
    when /rotate based on position of letter (\w+)/
      index = input.index($1)
      index += 1 if index >= 4
      index += 1
      index = -index
      input = input.chars.rotate(index).join
    when /reverse positions (\d+) through (\d+)/
      x = $1.to_i
      y = $2.to_i
      input[x..y] = input[x..y].reverse
    when /move position (\d+) to position (\d+)/
      x = $1.to_i
      x = input[x]
      input[x] = ''

      y = $2.to_i
      input.insert(y, x)
    else
      raise "invalid instruction: '#{instruction}'"
    end
  end
  input
end

input = 'abcdefgh'.chars
input.permutation.each do |candidate|
  if scramble(candidate.join) == 'fbgdceah'
    puts candidate.join
    exit
  end
end
