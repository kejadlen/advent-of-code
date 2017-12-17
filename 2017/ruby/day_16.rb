require "strscan"

@dance = ARGF.read.strip
@programs = (?a..?p).to_a

def run
  ss = StringScanner.new(@dance)
  until ss.eos?
    case
    when ss.scan(/s(\d+)/)
      @programs.rotate!(@programs.size - ss[1].to_i)
    when ss.scan(/x(\d+)\/(\d+)/)
      a, b = ss[1].to_i, ss[2].to_i
      @programs[a], @programs[b] = @programs[b], @programs[a]
    when ss.scan(/p(\w)\/(\w)/)
      a, b = @programs.index(ss[1]), @programs.index(ss[2])
      @programs[a], @programs[b] = @programs[b], @programs[a]
    when ss.scan(/,/)
    end
  end
end

@memoized = {}
count = 0
until @memoized.has_key?(@programs.join)
  @memoized[@programs.join] = count
  run
  count += 1
end

mod = 1_000_000_000 % count
p @memoized.find {|_,v| v == mod }.first
