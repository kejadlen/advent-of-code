banks = ARGF.read.strip.split("\t").map(&:to_i)

history = { banks => true}
count = 0
seen = false
loop do
  v, i = banks.map.with_index {|v,i| [v,i] }.max_by(&:first)
  banks[i] = 0
  i += 1
  while v > 0
    banks[i % banks.size] += 1
    v -= 1
    i += 1
  end
  count += 1
  if history.has_key?(banks)
    if seen
      puts count
      exit
    else
      history.clear
      seen = true
      count = 0
    end
  end
  history[banks] = true
end
