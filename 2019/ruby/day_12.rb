# typed: ignore

require "matrix"
require "prime"
require "set"

V = Vector
Moon = Struct.new(:id, :pos, :vel) do
  def potential_energy
    pos.map(&:abs).sum
  end

  def kinetic_energy
    vel.map(&:abs).sum
  end
end

class Moons < SimpleDelegator
  def self.from(input)
    moons = input
      .scan(/x=(-?\d+), y=(-?\d+), z=(-?\d+)/)
      .map.with_index {|x,i| Moon.new(i, V[*x.map(&:to_i)], V.zero(3)) }
    new(moons)
  end

  def step
    # apply gravity
    deltas = Hash.new  {|h,k| h[k] = V.zero(3) }
    combination(2).each do |a, b|
      delta = V[*a.pos.zip(b.pos).map {|a,b| a <=> b }]
      deltas[a] -= delta
      deltas[b] += delta
    end

    # apply velocity
    Moons.new(map {|m|
      v = m.vel + deltas.fetch(m)
      Moon.new(m.id, m.pos + v, v)
    })
  end

  def energy
    map {|m| m.potential_energy * m.kinetic_energy }.sum
  end

  def fingerprint(axis)
    map {|m| [m.pos[axis], m.vel[axis]] }
  end
end

require "minitest"

class TestMoons < Minitest::Test
  def setup
    @moons = Moons.from(<<~MOONS)
      <x=-1, y=0, z=2>
      <x=2, y=-10, z=-7>
      <x=4, y=-8, z=8>
      <x=3, y=5, z=-1>
    MOONS
  end

  def test_from
    assert_equal Moon.new(0, V[-1, 0, 2], V[0, 0, 0]), @moons.fetch(0)
    assert_equal Moon.new(3, V[3, 5, -1], V[0, 0, 0]), @moons.fetch(3)
  end

  def test_step
    moons = @moons.step

    assert_equal Moon.new(0, V[2, -1, 1], V[3, -1, -1]), moons.fetch(0)
    assert_equal Moon.new(3, V[2, 2, 0], V[-1, -3, 1]), moons.fetch(3)

    9.times do
      moons = moons.step
    end

    assert_equal Moon.new(0, V[2, 1, -3], V[-3, -2, 1]), moons.fetch(0)
    assert_equal Moon.new(3, V[2, 0, 4], V[1, -1, -1]), moons.fetch(3)
  end

  def test_energy
    10.times do
      @moons = @moons.step
    end

    assert_equal 179, @moons.energy
  end
end

def gcd(*n)
  n.map {|c| Prime.prime_division(c).to_h }
    .inject {|h,p| h.merge(p) {|_, a, b| [a, b].max }}
    .map {|n,e| n**e }
    .inject(&:*)
end

if ARGF.to_io.tty?
  require "minitest/autorun"
else
  moons = Moons.from(ARGF.read)

  # 1000.times do
  #   moons = moons.step
  # end
  # puts moons.energy

  seen = [{}, {}, {}]
  cycles = [nil, nil, nil]
  (0..).each do |step|
    if cycles.none?(&:nil?)
      puts gcd(*cycles.map(&:size))
      exit
    end

    (0..2).each do |i|
      seen[i][moons.fingerprint(i)] ||= step
    end

    moons = moons.step

    (0..2).each do |i|
      cycles[i] ||= (seen[i][moons.fingerprint(i)]..step) if seen[i].include?(moons.fingerprint(i))
    end
  end
end
