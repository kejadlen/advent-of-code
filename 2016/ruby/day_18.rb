class Row
  INPUT_MAP = { ?. => :safe, ?^ => :trap }

  attr_reader :tiles

  def initialize(input)
    @tiles = input.chars.map {|char| INPUT_MAP.fetch(char) }
  end
end

require 'minitest/autorun'

class TestRow < Minitest::Test
  def test_row
    row = Row.new('..^^.')
    assert_equal %i[ safe safe trap trap safe ], row.tiles
  end
end
