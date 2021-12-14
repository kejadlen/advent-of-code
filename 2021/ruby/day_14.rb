template, rules = ARGF.read.split("\n\n")
template = template.chars
rules = rules.scan(/(\w{2}) -> (\w)/).to_h

# polymer = template
# 10.times do
#   polymer = polymer.each_cons(2).flat_map {|a,b|
#     [a, rules.fetch("#{a}#{b}")]
#   } << polymer.last
# end

# min, max = polymer.tally.values.minmax
# p max - min

tally = Hash.new {|h,k|
  polymer, steps = k
  new_elements = polymer.each_cons(2).map(&:join).map { rules.fetch(_1) }
  h[k] = case steps
         when 1
           (polymer + new_elements).tally
         when (2..)
           initial = new_elements.tally.transform_values { -_1 }
           polymer.zip(new_elements)
             .flatten[0..-2]
             .each_cons(2)
             .map { h[[_1, steps-1]] }
             .inject(initial) {|final,tally| final.merge(tally) { _2 + _3 } }
         else
           fail
         end
}

final = tally[[template, 40]]

# correct for internal elements being double-counted
template[1..-2].each do
  final[_1] -= 1
end

min, max = final.values.minmax
p max - min
