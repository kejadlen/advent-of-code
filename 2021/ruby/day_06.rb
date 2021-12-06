ages = ARGF.read.split(?,).map(&:to_i)

# 80.times do
#   new_fish = 0
#   ages.map! {|age|
#     if age.zero?
#       new_fish += 1
#       6
#     else
#       age - 1
#     end
#   }
#   ages.concat(Array.new(new_fish) { 8 })
# end
# p ages.count

DURATION = 256
DESCENDANTS = Hash.new {|h,k|
  children = (k...DURATION).step(7)
  h[k] = children.count + children.map {|d| d + 9 }.select {|d| d < DURATION }.sum {|d| h[d] }
}
p ages.count + ages.sum {|age| DESCENDANTS[age] }
