Row = Struct.new(:tiles) do
  INPUT_MAP = { ?. => :safe, ?^ => :trap }

  def self.from_s(input)
    new(input.chars.map {|char| INPUT_MAP.fetch(char) })
  end

  def next
    self.class.new(
      %i[ safe safe ].insert(1, *tiles).each_cons(3).map {|l,c,r|
        if l == :trap && c == :trap && r == :safe
          :trap
        elsif l == :safe && c == :trap && r == :trap
          :trap
        elsif l == :trap && c == :safe && r == :safe
          :trap
        elsif l == :safe && c == :safe && r == :trap
          :trap
        else
          :safe
        end
      }
    )
  end
end

if __FILE__ == $0
  row = Row.from_s(DATA.read.chomp)
  count = 0
  400_000.times do
    count += row.tiles.count(:safe)
    row = row.next
  end
  p count
end

require 'minitest'
# require 'minitest/autorun'

class TestRow < Minitest::Test
  def test_row
    row = Row.from_s('..^^.')
    assert_equal %i[ safe safe trap trap safe ], row.tiles

    assert_equal Row.from_s('.^^^^'), row.next
  end
end

__END__
^^.^..^.....^..^..^^...^^.^....^^^.^.^^....^.^^^...^^^^.^^^^.^..^^^^.^^.^.^.^.^.^^...^^..^^^..^.^^^^
