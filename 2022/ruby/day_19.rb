SEEN = []

class Factory
  attr_reader :time, :robots, :resources

  def initialize(
    blueprint,
    time=0,
    robots={ ore: 1, clay: 0, obsidian: 0, geode: 0 },
    resources={ ore: 0, clay: 0, obsidian: 0, geode: 0 }
  )
    @blueprint = blueprint
    @time = time
    @robots = robots
    @resources = resources
  end

  def max_geodes
    if @time == 20
      pp self if @robots.values_at(:ore, :clay, :obsidian, :geode) == [1, 4, 2, 1]
      return @resources.fetch(:geode)
    end

    resources = @resources.merge(@robots) { _2 + _3 }
    branches = @blueprint.filter_map {|robot, cost|
      if cost.all? {|res, qty| @resources.fetch(res) >= qty }
        Factory.new(
          @blueprint,
          @time + 1,
          @robots.merge({robot => 1}) { _2 + _3 },
          resources.merge(cost) { _2 - _3 },
        )
      else
        nil
      end
    }

    if @blueprint.any? {|_, cost| cost.any? {|res, qty| @robots.fetch(res) > 0 && @resources.fetch(res) < qty }}
      pp self
      branches << Factory.new(@blueprint, @time + 1, @robots, resources)
    end

    branches = branches.reject {|factory|
      SEEN.any? {|other|
        %i[ ore clay obsidian geode ].all? {|res|
          factory.robots.fetch(res) <= other.robots.fetch(res) &&
          factory.resources.fetch(res) <= other.resources.fetch(res) &&
          factory.time >= other.time
        }
      }
    }
    SEEN.concat(branches)

    return @resources.fetch(:geode) if branches.empty?

    branches.map(&:max_geodes).max
  end

  def to_s
    "<time: #@time robots: #{@robots.values} resources: #{@resources.values}>"
  end
  alias_method :inspect, :to_s
end

blueprints = ARGF.read
  .split("\n\n").map { _1.lines(chomp: true).join }
  .map { _1.scan(/\d+/).map(&:to_i) }
  .map {
    _1.shift # id
    {
      ore: {ore: _1.shift },
      clay: {ore: _1.shift },
      obsidian: {ore: _1.shift, clay: _1.shift },
      geode: {ore: _1.shift, obsidian: _1.shift },
    }
  }

p Factory.new(blueprints[0]).max_geodes
p SEEN.count

__END__
Blueprint 1:
  Each ore robot costs 4 ore.
  Each clay robot costs 2 ore.
  Each obsidian robot costs 3 ore and 14 clay.
  Each geode robot costs 2 ore and 7 obsidian.

Blueprint 2:
  Each ore robot costs 2 ore.
  Each clay robot costs 3 ore.
  Each obsidian robot costs 3 ore and 8 clay.
  Each geode robot costs 3 ore and 12 obsidian.
