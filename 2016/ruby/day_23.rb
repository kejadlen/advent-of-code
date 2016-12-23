registers = { ?a => 7, ?b => 0, ?c => 0, ?d => 0 }
pc = 0
data = DATA.each_line.map(&:chomp).to_a

while pc < data.size
  line = data[pc]
  puts "#{registers}"
  puts "#{pc}: #{line}"

  case line
  when /cpy ([a-d]|-?\d+) ([a-d])/
    value = registers.fetch($1) { $1.to_i }
    registers[$2] = value
    pc += 1
  when /inc ([a-d])/
    registers[$1] += 1
    pc += 1
  when /dec ([a-d])/
    registers[$1] -= 1
    pc += 1
  when /jnz ([a-d]|\d+) ([a-d]|-?\d+)/
    value = registers.fetch($1) { $1.to_i }
    count = registers.fetch($2) { $2.to_i }
    pc += value.zero? ? 1 : count
  when /tgl ([a-d]|-?\d+)/
    value = registers.fetch($1) { $1.to_i }
    line = data[pc + value]
    if line.nil?
      pc +=1
      next
    end

    instruction, *args = line.split(/\s+/)

    case args.size
    when 1
      instruction = (instruction == 'inc') ? 'dec' : 'inc'
    when 2
      instruction = (instruction == 'jnz') ? 'cpy' : 'jnz'
    else
      raise 'omg'
    end

    data[pc + value] = "#{instruction} #{args.join(' ')}"

    pc += 1
  else
    puts "skipping line: #{line}"
    pc += 1
  end
end

p registers

__END__
cpy a b
dec b
cpy a d
cpy 0 a
cpy b c
inc a
dec c
jnz c -2
dec d
jnz d -5
dec b
cpy b c
cpy c d
dec d
inc c
jnz d -2
tgl c
cpy -16 c
jnz 1 c
cpy 94 c
jnz 82 d
inc a
inc d
jnz d -2
inc c
jnz c -5
