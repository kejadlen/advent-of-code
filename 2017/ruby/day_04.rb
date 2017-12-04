class Passphrase
  def initialize(raw)
    @raw = raw
  end

  def valid?
    words = @raw.split(/\s+/).map {|word| word.split(//).sort.join }
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
    # assert Passphrase.new("aa bb cc dd ee").valid?
    # refute Passphrase.new("aa bb cc dd aa").valid?
    # assert Passphrase.new("aa bb cc dd aaa").valid?

    assert Passphrase.new("abcde fghij").valid?
    refute Passphrase.new("abcde xyz ecdab").valid?
    assert Passphrase.new("a ab abc abd abf abj").valid?
    assert Passphrase.new("iiii oiii ooii oooi oooo").valid?
    refute Passphrase.new("oiii ioii iioi iiio").valid?
  end
end
