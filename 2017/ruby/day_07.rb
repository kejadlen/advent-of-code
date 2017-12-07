Program = Struct.new(:name, :weight, :disc)

programs = {}
File.read(File.expand_path("../input/day_07.txt")).strip.split("\n").each do |line|
  name, weight, above = line.scan(/(.+) \((\d+)\)(?: -> (.+))?/)[0]
  programs[name] = Program.new(name, weight.to_i, (above || "").split(", "))
end

disc_weights = Hash.new {|h,k|
  program = programs[k]
  h[k] = if program.disc.empty?
           program.weight
         else
           program.weight + program.disc.map {|x| h[programs[x].name] }.sum
         end
}

root = "mkxke"
p programs[root].disc.map {|n| [n, disc_weights[n]] }
require "pry"; binding.pry
