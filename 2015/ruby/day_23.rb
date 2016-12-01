class Computer < Struct.new(:instructions)
  INSTRUCTIONS = {
    hlf: ->(c,r) { c.registers[r] /= 2; c.pc += 1 },
    tpl: ->(c,r) { c.registers[r] *= 3; c.pc += 1 },
    inc: ->(c,r) { c.registers[r] += 1; c.pc += 1 },
    jmp: ->(c,o) { c.pc += o.to_i },
    jie: ->(c,r,o) { c.pc += (c.registers[r].even?) ? o.to_i : 1 },
    jio: ->(c,r,o) { c.pc += (c.registers[r] == 1) ? o.to_i : 1 },
  }

  attr_reader :registers
  attr_accessor :pc

  def initialize(*)
    super

    @registers = Hash.new(0)
    @pc = 0
  end

  def run!
    loop do
      instruction, *args = self.instructions[self.pc]
      break if instruction.nil?

      INSTRUCTIONS[instruction.to_sym].call(self, *args)
    end
  end
end

instructions = DATA.read.split("\n").map {|line| line.split(/,? /) }

c = Computer.new(instructions)
c.registers[?a] = 1
c.run!
p c.registers

__END__
jio a, +19
inc a
tpl a
inc a
tpl a
inc a
tpl a
tpl a
inc a
inc a
tpl a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
jmp +23
tpl a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
inc a
tpl a
inc a
tpl a
inc a
tpl a
inc a
inc a
tpl a
inc a
inc a
tpl a
tpl a
inc a
jio a, +8
inc b
jie a, +4
tpl a
inc a
jmp +2
hlf a
jmp -7
