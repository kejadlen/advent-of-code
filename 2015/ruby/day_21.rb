require "letters"

class Dude < Struct.new(*%i[ name hp damage armor ])
  def attack!(dude)
    damage = self.damage - dude.armor
    damage = 1 unless damage > 0

    dude.hp = dude.hp - damage
    return unless dude.hp > 0

    dude.attack!(self)
  end

  def equipped(equipment)
    self.class.new(name, hp,
                   self.damage + equipment.damage_bonus,
                   self.armor + equipment.armor_bonus)
  end

  def win_against?(dude)
    self_hp = self.hp
    dude_hp = dude.hp

    self.attack!(dude)
    result = (self.hp > 0)

    self.hp = self_hp
    dude.hp = dude_hp

    result
  end
end

Item = Struct.new(*%i[ name cost damage armor ])
NULL_ITEM = Item.new("Nothing", 0, 0, 0)

class Equipment < Struct.new(*%i[ weapon armor rings ])
  attr_accessor *%i[ cost damage_bonus armor_bonus ]

  def initialize(*)
    super

    equipment = [self.weapon, self.armor].concat(self.rings)
    self.cost = equipment.map(&:cost).inject(:+)
    self.damage_bonus = equipment.map(&:damage).inject(:+)
    self.armor_bonus = equipment.map(&:armor).inject(:+)
  end
end

weapons, armors, rings = DATA.read.split("\n\n").map {|set|
  set.split("\n").drop(1).map {|attrs|
    attrs = attrs.split(/\s+/)
    name = attrs[0..-4].join(" ")
    attrs = attrs[-3..-1].map(&:to_i)
    Item.new(name, *attrs)
  }
}
armors << NULL_ITEM
rings << NULL_ITEM
rings = rings.combination(2).to_a
rings << [NULL_ITEM, NULL_ITEM]

equipments = weapons.flat_map {|weapon|
  armors.flat_map {|armor|
    rings.flat_map {|rings|
      Equipment.new(weapon, armor, rings)
    }
  }
}.sort_by {|e| -e.cost }

BOSS = Dude.new("boss", 100, 8, 2)
YOU = Dude.new("you", 100, 0, 0)

puts equipments.find {|e|
  !YOU.equipped(e).win_against?(BOSS)
}.cost

__END__
Weapons:    Cost  Damage  Armor
Dagger        8     4       0
Shortsword   10     5       0
Warhammer    25     6       0
Longsword    40     7       0
Greataxe     74     8       0

Armor:      Cost  Damage  Armor
Leather      13     0       1
Chainmail    31     0       2
Splintmail   53     0       3
Bandedmail   75     0       4
Platemail   102     0       5

Rings:      Cost  Damage  Armor
Damage +1    25     1       0
Damage +2    50     2       0
Damage +3   100     3       0
Defense +1   20     0       1
Defense +2   40     0       2
Defense +3   80     0       3
