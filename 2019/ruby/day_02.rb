# typed: false
require_relative "computer"

program = ARGF.read.split(?,).map(&:to_i)

# modified = program.dup
# modified[1] = 12
# modified[2] = 2
# c = Computer.new(modified)
# puts c.each.inject(nil) {|_,i| i }.fetch(0)

noun, verb = (0..99).flat_map {|noun| (0..99).map {|verb| [noun, verb] } }
  .find {|(noun, verb)|
    modified = program.dup
    modified[1] = noun
    modified[2] = verb
    c = Computer.new(modified)
    final = c.run
    final.fetch(0) == 19690720
  }
puts 100 * noun + verb
