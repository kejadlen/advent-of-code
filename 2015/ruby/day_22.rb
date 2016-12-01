require "logger"

require "letters"
require "minitest"

class Dude
  attr_accessor *%i[ hp damage armor mana ]

  def initialize(hp:, damage: 0, armor: 0, mana: 0)
    @hp, @damage, @armor, @mana = hp, damage, armor, mana
  end
end

class Spell
  NOOP = ->(*){}

  attr_reader *%i[ name cost timer start effect finish ]

  def initialize(name, cost, timer: nil, start: NOOP, effect: NOOP, finish: NOOP)
    @name, @cost, @timer, @start, @effect, @finish = name, cost, timer, start, effect, finish
  end
end

SPELLS = [
  Spell.new(:magic_missile, 53, effect: ->(s) { s.boss.hp -= 4 }),
  Spell.new(:drain, 73, effect: ->(s) { s.boss.hp -= 2; s.player.hp += 2 }),
  Spell.new(:shield, 113, timer: 6,
                          start: ->(s) { s.player.armor += 7 },
                          finish: ->(s) { s.player.armor -= 7 }),
  Spell.new(:poison, 173, timer: 6, effect: ->(s) { s.boss.hp -= 3 }),
  Spell.new(:recharge, 229, timer: 5, effect: ->(s) { s.player.mana += 101 }),
]

class Effect < SimpleDelegator
  attr_accessor *%i[ timer ]

  def initialize(spell)
    super

    @timer = spell.timer
  end
end

class Simulation
  NOOP = ->(_){}

  attr_reader *%i[ boss player log ]
  attr_accessor *%i[ effects ]

  def initialize(boss:, player:, log:)
    @boss, @player, @log = boss, player, log
    @effects = []
  end

  def simulate!(spells)
    spells = spells.dup

    catch(:done) do
      while true
        spell = spells.shift
        throw :done if spell.nil?

        self.player.hp -= 1
        throw :done if self.player.hp <= 0

        self.apply_effects
        self.cast(spell)
        self.check!

        self.apply_effects
        damage = self.boss.damage - self.player.armor
        damage = [damage, 1].max
        self.player.hp -= damage
        self.check!
      end
    end
  end

  def apply_effects
    self.effects.each do |effect|
      effect.effect.call(self)
      effect.timer -= 1
    end

    finished, self.effects = self.effects.partition {|effect| effect.timer.zero? }
    finished.each do |effect|
      effect.finish.call(self)
    end

    self.check!
  end

  def cast(spell)
    throw :done if self.effects.map(&:name).include?(spell.name)

    self.player.mana -= spell.cost
    throw :done if self.player.mana < 0

    spell.start.call(self)

    if spell.timer.nil?
      spell.effect.call(self)
    else
      self.effects << Effect.new(spell)
    end
  end

  def check!
    throw :done if self.player.hp <= 0 ||
                   self.player.mana <= 0 ||
                   self.boss.hp <= 0
  end
end

class TestDay22 < Minitest::Test
  def test_basic
    s = Simulation.new(boss: Dude.new(hp: 13, damage: 8),
                       player: Dude.new(hp: 10, mana: 250))
    s.simulate!(%i[ magic_missile ])

    assert_equal 9, s.boss.hp
    assert_equal 2, s.player.hp
  end

  def test_example_1
    s = Simulation.new(boss: Dude.new(hp: 13, damage: 8),
                       player: Dude.new(hp: 10, mana: 250))
    s.simulate!(%i[ poison magic_missile ])

    assert_equal 0, s.boss.hp
    assert_equal 2, s.player.hp
    assert_equal 24, s.player.mana
  end

  def test_example_2
    s = Simulation.new(boss: Dude.new(hp: 14, damage: 8),
                       player: Dude.new(hp: 10, mana: 250))
    s.simulate!(%i[ recharge shield drain poison magic_missile ])

    assert_equal -1, s.boss.hp
    assert_equal 1, s.player.hp
    assert_equal 114, s.player.mana
  end
end

if __FILE__ == $0
  log = Logger.new(STDOUT)
  log.level = Logger::WARN

  num_spells = 0
  while true
    num_spells += 1
    puts num_spells

    permutations = SPELLS.repeated_permutation(num_spells)
                         .sort_by {|permutation| permutation.map(&:cost).inject(:+) }
    permutations.each do |spells|
      s = Simulation.new(boss: Dude.new(hp: 55, damage: 8),
                         player: Dude.new(hp: 50, mana: 500),
                         log: log)
      s.simulate!(spells)

      if s.player.hp > 0 && s.player.mana > 0 && s.boss.hp <= 0
        p spells.map(&:name)
        puts spells.map(&:cost).inject(:+)
        exit
      end
    end
  end
end
