require "set"

rules = ARGF.read.split("\n")
  .map {|line| line.split(" bags contain") }.to_h
  .transform_values {|v| v.scan(/(\d+) ([\w ]+) bags?/).map(&:reverse).to_h }

# bags = rules.select {|_,v| v.has_key?("shiny gold") }.map(&:first).to_set
# while true
#   bags.merge(bags.flat_map {|bag| rules.select {|_,v| v.has_key?(bag) }.map(&:first) })
#   p bags.size
# end

bags = Hash.new {|h,k|
  h[k] = rules.fetch(k).map {|k,v| v.to_i + h[k] * v.to_i }.sum
}
p bags["shiny gold"]
