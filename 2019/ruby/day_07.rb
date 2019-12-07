require_relative "computer"

program = ARGF.read

p (5..9).to_a.permutation.map {|phase_settings|
  amplifiers = Array.new(5) { Computer.from(program) }

  pipes = Array.new(5) { IO.pipe }

  # input phase settings
  pipes.zip(phase_settings).each do |(_, w), ps|
    w.puts(ps)
  end

  # first 0 signal
  pipes.first.last.puts(?0)

  ios = pipes.cycle.each_cons(2).take(5).map {|(r, _), (_, w)| [r, w] }

  ts = amplifiers.zip(ios).map {|(a, (i, o))|
    Thread.new { a.run(i, o) }
  }
  ts.each(&:join)

  thrusters_input = ios.first.first
  thrusters_input.gets.to_i
}.max
