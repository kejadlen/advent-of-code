require "set"

require "minitest"
require "minitest/pride"

class EndCombat < StandardError; end

class Combat
  def initialize(map, elf_attack)
    @map = map
    @attack = {
      Elf => elf_attack,
      Goblin => 3,
    }
  end

  def fight
    return enum_for(__method__) unless block_given?

    yield @map

    loop do
      turn_order.each do |pos|
        next if @map[pos].nil? # don't take a turn for units that just died

        turn = Turn.new(@map, pos)

        if move = turn.move
          unit = @map.delete(pos)
          @map[move] = unit
          turn.pos = move
        end

        if attack = turn.attack
          unit = @map.fetch(turn.pos)
          target = @map.fetch(attack)
          target.hp -= @attack.fetch(unit.class)
          @map.delete(attack) if target.hp <= 0
        end
      end

      yield @map
    end
  rescue EndCombat
    # yield @map
  end

  def turn_order
    @map.units.keys.sort
  end
end

class TestCombat < Minitest::Test
  def test_move
    map = Map.parse(<<~MAP)
      #########
      #G..G..G#
      #.......#
      #.......#
      #G..E..G#
      #.......#
      #.......#
      #G..G..G#
      #########
    MAP
    combat = Combat.new(map, 3)
    rounds = combat.fight
    rounds.next # skip the first round

    assert_equal <<~MAP.chomp, rounds.next.to_s
      #########
      #.G...G.#
      #...G...#
      #...E..G#
      #.G.....#
      #.......#
      #G..G..G#
      #.......#
      #########
    MAP

    assert_equal <<~MAP.chomp, rounds.next.to_s
      #########
      #..G.G..#
      #...G...#
      #.G.E.G.#
      #.......#
      #G..G..G#
      #.......#
      #.......#
      #########
    MAP

    assert_equal <<~MAP.chomp, rounds.next.to_s
      #########
      #.......#
      #..GGG..#
      #..GEG..#
      #G..G...#
      #......G#
      #.......#
      #.......#
      #########
    MAP
  end

  def test_fight
    map = Map.parse(<<~MAP)
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
    MAP
    combat = Combat.new(map, 3)
    rounds = combat.fight
    rounds.next # skip the initial state
    rounds.next # skip the first found

    map = rounds.next # second round
    assert_equal 188, map.fetch(Position[2,4]).hp

    20.times { rounds.next }
    assert_equal <<~MAP.chomp, rounds.next.to_s
      #######
      #...G.#
      #..G.G#
      #.#.#G#
      #...#E#
      #.....#
      #######
    MAP
  end

  def test_turn_order
    map = Map.parse(<<~MAP)
      #######
      #.G.E.#
      #E.G.E#
      #.G.E.#
      #######
    MAP
    combat = Combat.new(map, 3)

    expected = [[1,2], [1,4], [2,1], [2,3], [2,5], [3,2], [3,4]].map {|pos| Position[*pos]}
    assert_equal expected, combat.turn_order
  end
end

class Turn
  attr_accessor :pos

  def initialize(map, pos)
    @map, @pos = map, pos
    @unit = @map.fetch(@pos)
  end

  def move
    raise EndCombat if targets.empty?
    return if can_attack?
    return if nearest.empty?

    chosen = nearest.min
    haystack = @map.in_range(@pos)
    dijkstra(chosen)
      .select {|pos,_| haystack.include?(pos) }
      .min_by {|pos,distance| [distance, pos] }
      .first
  end

  def attack
    attackable.min_by {|pos, target| [target.hp, pos] }&.first
  end

  def targets
    @map.units.select {|_, other| other.is_a?(@unit.enemy) }
  end

  def attackable
    targets.select {|pos, _| @pos.adjacent.include?(pos) }
  end

  def can_attack?
    !attackable.empty?
  end

  def in_range
    targets.flat_map {|pos, _| @map.in_range(pos) }.uniq
  end

  def reachable
    dijkstra(@pos).select {|pos,_| in_range.include?(pos) }
  end

  def nearest
    nearest = Hash.new {|h,k| h[k] = [] }
    reachable.each do |pos, distance|
      nearest[distance] << pos
    end

    return [] if nearest.empty?
    nearest.min_by(&:first).last
  end

  private

  def dijkstra(pos)
    distances = { pos => 0 }
    queue = [ pos ]
    while pos = queue.shift
      distance = distances.fetch(pos) + 1
      @map.in_range(pos).reject {|pos| distances.has_key?(pos) }.each do |pos|
        distances[pos] = distance
        queue << pos
      end
    end
    distances
  end
end

class TestTurn < Minitest::Test
  def setup
    map = Map.parse(<<~MAP)
      #######
      #E..G.#
      #...#.#
      #.G.#G#
      #######
    MAP
    @turn = Turn.new(map, Position[1,1])
  end

  def test_targets
    assert_equal [[1,4], [3,2], [3,5]].to_set, @turn.targets.keys.map(&:to_a).to_set
  end

  def test_in_range
    assert_equal [[1,3], [1,5], [2,2], [2,5], [3,1], [3,3]].to_set, @turn.in_range.map(&:to_a).to_set
  end

  def test_reachable
    assert_equal [[1,3], [2,2], [3,1], [3,3]].to_set, @turn.reachable.keys.map(&:to_a).to_set
  end

  def test_nearest
    assert_equal [[1,3], [2,2], [3,1]].to_set, @turn.nearest.map(&:to_a).to_set
  end

  def test_move
    assert_equal Position[1,2], @turn.move

    turn = Turn.new(Map.parse(<<~MAP), Position[1,2])
      #######
      #.E...#
      #.....#
      #...G.#
      #######
    MAP
    assert_equal Position[1,3], turn.move
  end
end

class Map
  def self.parse(s)
    occupied = {}
    s.chomp.lines.each.with_index do |row, y|
      row.chomp.chars.each.with_index do |square, x|
        case square
        when ?#
          occupied[Position[y, x]] = Wall.new
        when ?E
          occupied[Position[y, x]] = Elf.new
        when ?G
          occupied[Position[y, x]] = Goblin.new
        when ?.
        else
          fail "Invalid character: #{square.inspect}"
        end
      end
    end
    self.new(occupied)
  end

  def initialize(occupied)
    @occupied = occupied
  end

  def [](pos)
    @occupied[pos]
  end

  def []=(pos, square)
    @occupied[pos] = square
  end

  def fetch(pos)
    @occupied.fetch(pos)
  end

  def delete(pos)
    @occupied.delete(pos)
  end

  def units
    @occupied.select {|_, sq| sq.is_a?(Unit) }
  end

  def in_range(pos)
    pos
      .adjacent
      .reject {|pos| @occupied.has_key?(pos) }
  end

  def to_s
    max_y = @occupied.keys.map(&:y).max
    max_x = @occupied.keys.map(&:x).max
    (0..max_y).map {|y|
      (0..max_x).map {|x|
        case @occupied[Position[y, x]]
        when Wall
          ?#
        when Elf
          ?E
        when Goblin
          ?G
        when nil
          ?.
        else
          fail "Unexpected object: #{@occupied[Position[y, x]]}"
        end
      }.join
    }.join(?\n)
  end
end

class TestMap < Minitest::Test
  def test_parse
    map = Map.parse(<<~MAP)
      #######
      #E..G.#
      #...#.#
      #.G.#G#
      #######
    MAP

    assert_instance_of Wall, map[Position[0,0]]
    assert_instance_of Wall, map[Position[2,4]]
    assert_instance_of Wall, map[Position[4,6]]

    assert_instance_of Elf, map[Position[1,1]]

    assert_instance_of Goblin, map[Position[1,4]]
    assert_instance_of Goblin, map[Position[3,5]]

    assert_nil map[Position[1,2]]
    assert_nil map[Position[2,5]]
  end

  def test_units
    map = Map.parse(<<~MAP)
      #######
      #E..G.#
      #...#.#
      #.G.#G#
      #######
    MAP

    assert_equal 4, map.units.length
  end
end

Position = Struct.new(:y, :x) do
  def self.[](y, x)
    self.new(y, x)
  end

  def <=>(other)
    [self.y, self.x] <=> [other.y, other.x]
  end

  def adjacent
    [-1, 1]
      .flat_map {|d| [[y, x+d], [y+d, x]] }
      .map {|pos| Position[*pos] }
  end

  def to_a
    [y, x]
  end

  def to_s
    to_a.to_s
  end
end

class Unit
  attr_accessor :hp

  def initialize
    @hp = 200
  end

  def to_s
    "#{self.class.name.chars.first}(#{hp})"
  end
end

class Wall
end

class Elf < Unit
  def enemy
    Goblin
  end
end

class Goblin < Unit
  def enemy
    Elf
  end
end

def solve(input)
  (3..Float::INFINITY).each do |elf_attack|
    map = Map.parse(input)
    outcome = simulate(map, elf_attack)
    next if outcome.nil?
    return outcome
  end
end

def simulate(map, elf_attack)
  elf_count = map.units.count {|_, unit| unit.is_a?(Elf) }
  combat = Combat.new(map, elf_attack)
  map, count = combat.fight.map.with_index
    .inject(nil) {|last,(map,count)|
      return if map.units.count {|_, unit| unit.is_a?(Elf) } < elf_count
      # puts map, map.units.values.map(&:to_s).inspect
      [map, count]
  }
  return if map.units.count {|_, unit| unit.is_a?(Elf) } < elf_count
  map.units.values.map(&:hp).sum * count
end

class TestSolve < Minitest::Test
  def test_solve
    # assert_equal 27730, solve(<<~INPUT)
    assert_equal 4988, solve(<<~INPUT)
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
    INPUT

    # assert_equal 36334, solve(<<~INPUT)
      ########
      ##G..#E#
      ##E#E.E#
      ##G.##.#
      ##...#E#
      ##...E.#
      ########
    #INPUT

    # assert_equal 39514, solve(<<~INPUT)
    assert_equal 31284, solve(<<~INPUT)
      #######
      #E..EG#
      #.#G.E#
      #E.##E#
      #G..#.#
      #..E#.#
      #######
    INPUT

    # assert_equal 27755, solve(<<~INPUT)
    assert_equal 3478, solve(<<~INPUT)
      #######
      #E.G#.#
      #.#G..#
      #G.#.G#
      #G..#.#
      #...E.#
      #######
    INPUT

    # assert_equal 28944, solve(<<~INPUT)
    assert_equal 6474, solve(<<~INPUT)
      #######
      #.E...#
      #.#..G#
      #.###.#
      #E#G#G#
      #...#G#
      #######
    INPUT

    # assert_equal 18740, solve(<<~INPUT)
    assert_equal 1140, solve(<<~INPUT)
      #########
      #G......#
      #.E.#...#
      #..##..G#
      #...##..#
      #...#...#
      #.G...G.#
      #.....G.#
      #########
    INPUT
  end
end

if __FILE__ == $0
  require "minitest/autorun" and exit if ENV["TEST"]

  puts solve(ARGF.read)
end
