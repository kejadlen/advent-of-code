require "set"

Food = Struct.new(:id, :ingredients, :allergens)

foods = ARGF.read
  .scan(/(.+) \(contains (.+)\)/)
  .map.with_index {|(ingredients, allergens), i|
    ingredients, allergens = [ ingredients.split(" "), allergens.split(", ") ].map {|x| Set.new(x) }
    Food.new(i, ingredients, allergens)
  }

all_ingredients = foods.map(&:ingredients).inject(&:|)

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

p foods.map {|f| f.ingredients.count {|i| no_allergens.include?(i) }}.sum

