lines = ARGF.readlines(chomp: true)

# part one
p lines
  .map { _1.chars.select {|c| c =~ /\d/ }}
  .map { _1.values_at(0, -1) }
  .sum { _1.join.to_i }

# part two
spellings = %w[
  one two three four five six seven eight nine
].each.with_index.to_h { [_1, _2 + 1] }
digits = (spellings.keys + spellings.values).join(?|)
first_re = /(#{digits})(?~#{digits})/
last_re = /.*(#{digits})/

p lines
  .sum { |line|
    [first_re, last_re]
      .map { _1.match(line)[1] }
      .map { spellings.fetch(_1, &:to_i) }
      .join
      .to_i
  }
