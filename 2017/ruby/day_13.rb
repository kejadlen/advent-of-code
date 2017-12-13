firewall = Hash[ARGF.read.strip.scan(/(\d+): (\d+)/).map {|x| x.map(&:to_i) }]

def caught?(time, range)
  (time % (2 * (range - 1))).zero?
end

p firewall.select {|depth, range| caught?(depth, range) }.map {|d,r| d * r }.sum

p (1..Float::INFINITY).find {|delay|
  firewall.none? {|depth, range| caught?(delay+depth, range) }
}
