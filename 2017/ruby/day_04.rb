class Passphrase
  def initialize(raw)
    @raw = raw
  end

  def valid?
    words = @raw.split(/\s+/)
    words.uniq.size == words.size
  end
end

# require "minitest/autorun"
if $0 == __FILE__
  p ARGF.read.split("\n").map {|line| Passphrase.new(line) }.select(&:valid?).size
end

require "minitest"
class TestPassphrase < Minitest::Test
  def test_valid
    assert Passphrase.new("aa bb cc dd ee").valid?
    refute Passphrase.new("aa bb cc dd aa").valid?
    assert Passphrase.new("aa bb cc dd aaa").valid?
  end
end
