require "set"

@programs = Hash[
  ARGF.read.strip
    .lines
    .map {|line| line.scan(/\d+/).map(&:to_i) }
    .map {|x| [x.shift, x] }
]

def group(id)
  group = Set.new
  queue = [id]
  until queue.empty?
    program = queue.shift
    next if group.include?(program)
    group << program
    queue = queue.concat(@programs[program])
  end
  group
end

p group(0).size

count = 0
until @programs.empty?
  group(@programs.keys.first).each do |program|
    @programs.delete(program)
  end
  count += 1
end
p count
