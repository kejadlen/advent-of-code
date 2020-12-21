require "set"

Food = Struct.new(:id, :ingredients, :allergens)

foods = ARGF.read
  .scan(/(.+) \(contains (.+)\)/)
  .map.with_index {|(ingredients, allergens), i|
    ingredients, allergens = [ ingredients.split(" "), allergens.split(", ") ].map {|x| Set.new(x) }
    Food.new(i, ingredients, allergens)
  }

all_ingredients = foods.map(&:ingredients).inject(&:|)
all_allergens = foods.map(&:allergens).inject(&:|)

no_allergens = all_ingredients.select {|ingredient|
  possible_allergens = foods
    .select {|food| food.ingredients.include?(ingredient) }
    .map(&:allergens)
    .inject(&:|)
  possible_allergens.none? {|allergen|
    foods_with_allergen = foods.select {|f| f.allergens.include?(allergen) }
    foods_with_allergen.all? {|f| f.ingredients.include?(ingredient) }
  }
}

# part one
# p foods.map {|f| f.ingredients.count {|i| no_allergens.include?(i) }}.sum

known, unknown = all_allergens.map {|a|
  [a, foods.select {|f| f.allergens.include?(a) }.map(&:ingredients).inject(&:&) ]
}.to_h.partition {|_,v| v.size == 1 }.map(&:to_h)

until unknown.empty?
  unknown.transform_values! {|v| v - known.values.inject(&:|) }
  new_known, unknown = unknown.partition {|_,v| v.size == 1 }.map(&:to_h)
  known.merge!(new_known)
end

p known.transform_values {|v| v.to_a.first }.sort_by(&:first).map(&:last).join(?,)
