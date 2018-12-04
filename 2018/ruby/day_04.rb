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

guard, (minute, _) = stats.map {|k,v|
  [k, v.flat_map(&:to_a).group_by {|x| x }.max_by {|_,v| v.count }]
}.max_by {|_,(_,v)| v.count }
p guard * minute
