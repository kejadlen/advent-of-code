regex = /(\w+): capacity (-?\d+), durability (\d+), flavor (-?\d+), texture (-?\d+), calories (\d+)/
ingredients = Hash[DATA.read.scan(regex).map {|name, *attrs| [name, attrs.map(&:to_i)] }]
max = 0
(0..100).each do |i|
  (0..100-i).each do |j|
    (0..100-i-j).each do |k|
      l = 100-i-j-k
      a = [i,j,k,l]
      s = (0..4).map {|s|
        ingredients.values.map {|x| x[s] }.zip(a).map {|x,y| x*y }.inject(:+)
      }.map {|s|
        [s,0].max
      }
      cals = s.pop
      s = s.inject(:*)
      if s > max && cals == 500
        max = s
        p a, s
      end
    end
  end
end
__END__
Sugar: capacity 3, durability 0, flavor 0, texture -3, calories 2
Sprinkles: capacity -3, durability 3, flavor 0, texture 0, calories 9
Candy: capacity -1, durability 0, flavor 4, texture 0, calories 1
Chocolate: capacity 0, durability 0, flavor -2, texture 2, calories 8
