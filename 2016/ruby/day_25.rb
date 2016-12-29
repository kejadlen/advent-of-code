class Assembunny
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def run(input)
    return enum_for(__method__, input) unless block_given?

    registers = { ?a => input, ?b => 0, ?c => 0, ?d => 0 }
    pc = 0

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
      when /out ([a-d])/
        yield registers.fetch($1)
        pc += 1
      else
        raise "invalid line: #{line}"
      end
    end
  end
end

assembunny = Assembunny.new(ARGF.read.split("\n"))

needle = ('01' * 6).chars.map(&:to_i)
puts (1..Float::INFINITY).find {|i| assembunny.run(i).take(12) == needle }
