Disc = Struct.new(:positions, :start_position) do
  def position_at(time)
    (start_position + time) % positions
  end
end

discs = DATA.each_line.map {|line|
  /Disc #\d has (?<positions>\d+) positions; at time=0, it is at position (?<position>\d+)./ =~ line
  Disc.new(positions.to_i, position.to_i)
}

p (0..Float::INFINITY).find {|t|
  discs.each.with_index.all? {|disc, index|
    disc.position_at(t + index) == 0
  }
}

__END__
Disc #1 has 5 positions; at time=0, it is at position 4.
Disc #2 has 2 positions; at time=0, it is at position 1.
