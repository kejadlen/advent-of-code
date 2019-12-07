# typed: strict

require "stringio"

require "sorbet-runtime"

AnyIO = T.type_alias { T.any(IO, StringIO) }
Memory = T.type_alias { T::Array[T.nilable(Integer)] }

class Mode < T::Enum
  enums do
    Position = new
    Immediate = new
  end
end

OPCODES = T.let({
  1  => ->(m, _, _, a, b, c) { m[c] = m[a] + m[b]           ; nil }, # add
  2  => ->(m, _, _, a, b, c) { m[c] = m[a] * m[b]           ; nil }, # multiply
  3  => ->(m, i, _, a)       { m[a] = i.gets.to_i           ; nil }, # input
  4  => ->(m, _, o, a)       { o.puts(m[a])                 ; nil }, # output
  5  => ->(m, _, _, a, b)    { m[a].nonzero? ? m[b]         : nil }, # jump-if-true
  6  => ->(m, _, _, a, b)    { m[a].zero? ? m[b]            : nil }, # jump-if-false
  7  => ->(m, _, _, a, b, c) { m[c] = (m[a] < m[b])  ? 1 : 0; nil }, # less than
  8  => ->(m, _, _, a, b, c) { m[c] = (m[a] == m[b]) ? 1 : 0; nil }, # equals
  99 => ->(*)                { throw :halt                        }, # halt
}, T::Hash[T.untyped, T.untyped])

class Parameter
  extend T::Sig

  sig {params(value: T.any(Parameter, Integer)).returns(Parameter)}
  def self.from(value)
    case value
    when Parameter
      value
    when Integer
      new(Mode::Position, value)
    else
      T.absurd(value)
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

  sig {returns(AnyIO)}
  attr_reader :input, :output

  sig {params(program: Memory, input: AnyIO, output: AnyIO).void}
  def initialize(program, input=STDIN, output=STDOUT)
    @memory = T.let(program.dup, Memory)
    @input = T.let(input, AnyIO)
    @output = T.let(output, AnyIO)
    @pc = T.let(0, Integer)
  end

  sig {params(input: AnyIO, output: AnyIO).returns(Memory)}
  def run(input=STDIN, output=STDOUT)
    each(input, output).inject(nil) {|_,i| i }
  end

  sig {
    params(
      input: AnyIO,
      output: AnyIO,
      blk: T.nilable(T.proc.params(m: Memory).returns(T.nilable(Integer)))
    ).returns(T::Enumerator[Memory])
  }
  def each(input, output, &blk)
    return enum_for(T.must(__method__), input, output) unless block_given?

    catch(:halt) do
      loop do
        instruction = @memory[@pc].to_s.rjust(5, ?0)
        opcode = OPCODES.fetch(instruction[-2..-1].to_i)
        @pc += 1

        n = opcode.arity - 3
        args = (0...n).map {|i|
          mode = instruction[2-i] { ?0 }
          value = @memory.fetch(@pc + i) || 0
          mode = case mode
                 when ?0 then Mode::Position
                 when ?1 then Mode::Immediate
                 else fail "unexpected mode: #{mode}"
                 end
          Parameter.new(mode, value)
        }
        @pc += n

        @pc = opcode.call(self, input, output, *args) || @pc

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
    when Mode::Position  then @memory.fetch(parameter.value) || 0
    when Mode::Immediate then parameter.value
    else T.absurd(mode)
    end
  end
  alias_method :fetch, :[]

  sig {params(parameter: Parameter, value: Integer).void}
  def []=(parameter, value)
    raise "writes should never be in immediate mode" if parameter.mode == Mode::Immediate

    @memory[parameter.value] = value
  end
end
