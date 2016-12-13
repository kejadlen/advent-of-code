registers = { ?a => 0, ?b => 0, ?c => 1, ?d => 0 }
pc = 0
data = DATA.each_line.to_a

while pc < data.size
  line = data[pc]
  case line
  when /cpy ([a-d]|\d+) ([a-d])/
    value = registers.fetch($1) { $1.to_i }
    registers[$2] = value
    pc += 1
  when /inc ([a-d])/
    registers[$1] += 1
    pc += 1
  when /dec ([a-d])/
    registers[$1] -= 1
    pc += 1
  when /jnz ([a-d]|\d+) (-?\d+)/
    value = registers.fetch($1) { $1.to_i }
    pc += value.zero? ? 1 : $2.to_i
  else
    raise "invalid line: #{line}"
  end
end

p registers

__END__
cpy 1 a
cpy 1 b
cpy 26 d
jnz c 2
jnz 1 5
cpy 7 c
inc d
dec c
jnz c -2
cpy a c
inc a
dec b
jnz b -2
cpy c b
dec d
jnz d -6
cpy 16 c
cpy 17 d
inc a
dec d
jnz d -2
dec c
jnz c -5
