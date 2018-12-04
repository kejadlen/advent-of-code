records = ARGF.read.chomp.lines.map(&:chomp).sort
# puts records

stats = Hash.new {|h,k| h[k] = [] }

guard = nil
fell_asleep_at = nil
records.each do |record|
  if record =~ /\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\] Guard \#(\d+) begins shift/
    guard = $1.to_i
  elsif record =~ /\[\d{4}-\d{2}-\d{2} \d{2}:(\d{2})\] falls asleep/
    fell_asleep_at = $1.to_i
  elsif record =~ /\[\d{4}-\d{2}-\d{2} \d{2}:(\d{2})\] wakes up/
    stats[guard] << (fell_asleep_at...$1.to_i)
  else
    p record
  end
end

# Part One
guard, ranges = stats.max_by {|_,v| v.map(&:size).sum }
minute = ranges.flat_map(&:to_a).group_by {|x| x }.transform_values(&:count).max_by(&:last).first
p guard * minute

# Part Two
guard, (minute, _) = stats.map {|k,v|
  [k, v.flat_map(&:to_a).group_by {|x| x }.transform_values(&:count).max_by(&:last)]
}.max_by {|_,(_,v)| v }
p guard * minute
