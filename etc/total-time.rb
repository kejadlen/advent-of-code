seconds = ARGF.read.strip.lines(chomp: true)
  .sum {|line|
    line.strip.split(/\s+/).fetch(4)
      .split(?:).map(&:to_i)
      .zip([60*60, 60, 1])
      .sum { _1 * _2 }
  }

hours, seconds = seconds.divmod(60 * 60)
minutes, seconds = seconds.divmod(60)

puts "#{hours} hours, #{minutes} minutes, #{seconds} seconds"
