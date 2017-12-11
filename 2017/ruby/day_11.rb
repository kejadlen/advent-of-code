dirs = ARGF.read.strip.split(?,)
current = [0, 0, 0]
max = 0
dirs.each do |dir|
  delta = case dir
          when "nw"
            [-1, 1, 0]
          when "n"
            [0, 1, -1]
          when "ne"
            [1, 0, -1]
          when "sw"
            [-1, 0, 1]
          when "s"
            [0, -1, 1]
          when "se"
            [1, -1, 0]
          else
            raise "omg!"
          end
  current = current.zip(delta).map {|a,b| a + b }
  max = [max, current.map(&:abs).sum / 2].max
end
p current
p current.map(&:abs).sum / 2
p max
