require_relative "computer"

program = ARGF.read

puts (0..4).to_a.permutation.map {|phase_settings|
  amplifiers = Array.new(5) { Computer.from(program) }
  amplifiers.zip(phase_settings).inject(?0) {|i, (a, ps)|
    output = StringIO.new
    a.run(StringIO.new("#{ps}\n#{i}"), output)
    output.string
  }.to_i
}.max
