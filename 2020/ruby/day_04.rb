FIELDS = {
  byr: ->(s) { s =~ /^\d{4}$/ && (1920..2002).cover?(s.to_i) },
  iyr: ->(s) { s =~ /^\d{4}$/ && (2010..2020).cover?(s.to_i) },
  eyr: ->(s) { s =~ /^\d{4}$/ && (2020..2030).cover?(s.to_i) },
  hgt: ->(s) {
    s =~ /^(\d+)(cm|in)$/
    case $2
    when "cm"
      (150..193).cover?($1.to_i)
    when "in"
      (59..76).cover?($1.to_i)
    else
      false
    end
  },
  hcl: ->(s) { s =~ /^#[0-9a-f]{6}$/ },
  ecl: ->(s) { s =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/ },
  pid: ->(s) { s =~ /^\d{9}$/ },
  cid: ->(s) { true },
}

puts ARGF.read.split("\n\n").map {|line| line.scan(/(\w+):(\S+)/).to_h }
  .count {|passport|
    FIELDS.map {|k,v| v[passport.fetch(k.to_s, "")] }.all?
  }
