Disc = Struct.new(:positions, :start_position) do
  def position_at(time)
    (start_position + time) % positions
  end
end

discs = DATA.each_line.map {|line|
  /Disc #\d has (?<positions>\d+) positions; at time=0, it is at position (?<position>\d+)./ =~ line
  Disc.new(positions.to_i, position.to_i)
}
discs << Disc.new(11, 0)

p (0..Float::INFINITY).find {|t|
  discs.each.with_index.all? {|disc, index|
    disc.position_at(t + index) == 0
  }
}

__END__
Disc #1 has 17 positions; at time=0, it is at position 15.
Disc #2 has 3 positions; at time=0, it is at position 2.
Disc #3 has 19 positions; at time=0, it is at position 4.
Disc #4 has 13 positions; at time=0, it is at position 2.
Disc #5 has 7 positions; at time=0, it is at position 2.
Disc #6 has 5 positions; at time=0, it is at position 0.
