# typed: strict

require "stringio"

require "sorbet-runtime"

AnyIO = T.type_alias { T.any(IO, StringIO) }
Memory = T.type_alias { T::Array[T.nilable(Integer)] }

class Mode < T::Enum
  enums do
    Position = new
    Immediate = new
    Relative = new
  end

  extend T::Sig

  sig {params(value: String).returns(Mode)}
  def self.from(value)
    case value
    when ?0 then Mode::Position
    when ?1 then Mode::Immediate
    when ?2 then Mode::Relative
    else fail "unexpected mode: #{value}"
    end
  end
end

OPCODES = T.let({
  1  => ->(x, _, _, a, b, c) { x[c]  = x[a] + x[b]            }, # add
  2  => ->(x, _, _, a, b, c) { x[c]  = x[a] * x[b]            }, # multiply
  3  => ->(x, i, _, a)       { x[a]  = i.gets.to_i            }, # input
  4  => ->(x, _, o, a)       {         o.puts(x[a])           }, # output
  5  => ->(x, _, _, a, b)    { x.pc  = x[b] if x[a].nonzero?  }, # jump-if-true
  6  => ->(x, _, _, a, b)    { x.pc  = x[b] if x[a].zero?     }, # jump-if-false
  7  => ->(x, _, _, a, b, c) { x[c]  = (x[a] < x[b])  ? 1 : 0 }, # less than
  8  => ->(x, _, _, a, b, c) { x[c]  = (x[a] == x[b]) ? 1 : 0 }, # equals
  9  => ->(x, _, _, a)       { x.rb += x[a]                   }, # adjust relative base
  99 => ->(*)                {         throw :halt            }, # halt
}, T::Hash[Integer, T.untyped])

class Parameter
  extend T::Sig

  sig {params(value: T.any(Parameter, Integer)).returns(Parameter)}
  def self.from(value)
    case value
    when Parameter then value
    when Integer then new(Mode::Position, value)
    else T.absurd(value)
    end
  end

  sig {returns(Mode)}
  attr_reader :mode

  sig {returns(Integer)}
  attr_reader :value

  sig {params(mode: Mode, value: Integer).void}
  def initialize(mode, value)
    @mode = T.let(mode, Mode)
    @value = T.let(value, Integer)
  end
end

class Computer
  extend T::Sig

  sig {params(input: String).returns(Computer)}
  def self.from(input)
    new(input.split(?,).map(&:to_i))
  end

  sig {returns(Integer)}
  attr_accessor :pc, :rb

  sig {params(program: Memory).void}
  def initialize(program)
    @memory = T.let(program.dup, Memory)
    @pc = T.let(0, Integer)
    @rb = T.let(0, Integer)
  end

  sig {params(input: T.untyped, output: AnyIO).returns(Memory)}
  def run(input=STDIN, output=STDOUT)
    each(input, output).inject(nil) {|_,i| i }
  end

  sig {
    params(
      input: T.untyped,
      output: AnyIO,
      blk: T.nilable(T.proc.params(m: Memory).returns(T.nilable(Integer)))
    ).returns(T::Enumerator[Memory])
  }
  def each(input, output, &blk)
    return enum_for(T.must(__method__), input, output) unless block_given?

    catch(:halt) do
      loop do
        instruction = @memory[pc].to_s.rjust(5, ?0)
        opcode = OPCODES.fetch(instruction[-2..-1].to_i)
        self.pc += 1

        n = opcode.arity - 3 # subtract the computer, input, and output params
        args = (0...n).map {|i|
          mode = Mode.from(T.must(instruction[2-i]))
          value = @memory[pc + i] || 0
          Parameter.new(mode, value)
        }
        self.pc += n

        opcode.call(self, input, output, *args)

        yield @memory
      end
    end

    # Satisfy sorbet:
    #   https://sorbet-ruby.slack.com/archives/CHN2L03NH/p1575648549254600
    Enumerator.new {}
  end

  sig {params(parameter: Parameter).returns(Integer)}
  def [](parameter)
    parameter = Parameter.from(parameter)
    mode = parameter.mode
    case mode
    when Mode::Position  then @memory[parameter.value] || 0
    when Mode::Immediate then parameter.value
    when Mode::Relative  then @memory[rb + parameter.value] || 0
    else T.absurd(mode)
    end
  end
  alias_method :fetch, :[]

  sig {params(parameter: Parameter, value: Integer).void}
  def []=(parameter, value)

    mode = parameter.mode
    case mode
    when Mode::Position  then @memory[parameter.value] = value
    when Mode::Immediate then raise "writes should never be in immediate mode"
    when Mode::Relative then @memory[rb + parameter.value] = value
    else T.absurd(mode)
    end
  end
end

if __FILE__ == $0
  Computer.from(T.cast(ARGF, IO).read || "").run
end
