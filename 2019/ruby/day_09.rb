require_relative "computer"

program = ARGF.read
c = Computer.from(program)

c.run(StringIO.new("2"))
