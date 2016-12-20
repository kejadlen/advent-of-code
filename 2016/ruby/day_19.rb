def solve(n, debug: false)
  elves = Array.new(n) {|i| i+1 }

  until elves.size == 1
    across = elves.size / 2
    elves.delete_at(across)
    elves.rotate!
  end

  elves.first
end

# This takes too long
# n = 3017957
# puts solve(n)

# So instead use this to find the pattern!
(1..100).each do |i|
  puts "#{i}: #{solve(i)}"
end

# At 3**n, the counter resets
# At 2*3**n, the counter goes up by two instead of one
include Math
def formula(n)
  x = log(n, 3).to_i
  a = 3**x
  b = 2*a

  (n == a) ? a : n - a + [(n - b), 0].max
end

(1..100).each do |n|
  puts "#{n}: #{solve(n)} #{formula(n)}"
end
