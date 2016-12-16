def step(a)
  b = a.reverse.tr('10', '01')
  "#{a}0#{b}"
end

def checksum(data)
  checksum = data.chars
  loop do
    checksum = checksum.each_slice(2).map {|a,b| (a == b) ??1:?0 }
    break if checksum.length.odd?
  end
  checksum.join
end

seed = '10001110011110000'
target_length = 35651584

state = seed
while state.length < target_length
  state = step(state)
end

data = state[0...target_length]
puts checksum(data)
