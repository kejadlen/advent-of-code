require "strscan"

@dance = ARGF.read.strip
@programs = (?a..?p).to_a

def run
  ss = StringScanner.new(@dance)
  until ss.eos?
    case
    when ss.scan(/s/)
      spin = ss.scan(/\d+/).to_i
      @programs.rotate!(@programs.size - spin)
    when ss.scan(/x/)
      a = ss.scan(/\d+/).to_i
      ss.scan(/\//)
      b = ss.scan(/\d+/).to_i
      @programs[a], @programs[b] = @programs[b], @programs[a]
    when ss.scan(/p/)
      a = @programs.index(ss.scan(/\w/))
      ss.scan(/\//)
      b = @programs.index(ss.scan(/\w/))
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
