# typed: false
require_relative "computer"

program = ARGF.read.split(?,).map(&:to_i)
computer = Computer.new(program)
computer.run(StringIO.new("5\n"))
