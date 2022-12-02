p ARGF.read.strip.lines(chomp: true).map(&:split).map {|a,b|
  a = a.ord - ?A.ord
  b = b.ord - ?X.ord

  # part 2
  b = (a + b - 1) % 3

  outcome = case
            when (a + 1) % 3 == b then 6
            when a == b           then 3
            else                       0
            end
  outcome + b + 1
}.sum
