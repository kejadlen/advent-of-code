diagram = ARGF.read.split("\n").map(&:chars)

dir = [0, 1]
y = 0
x = diagram[y].index(?|)

begin
  steps = 0
  loop do
    case diagram[y][x]
    when ?+
      dir = if dir[0] == 0 # going vertically
              if (diagram[y][x-1] || " ") != " "
                [-1, 0]
              else
                [1, 0]
              end
            else # going horizontally
              if (diagram[y-1][x] || " ") != " "
                [0, -1]
              else
                [0, 1]
              end
            end
    when /[a-z]/i
      # print diagram[y][x]
    when /\||\+|-/
    else
      raise diagram[y][x]
    end
    x,y = [x,y].zip(dir).map {|a,b| a + b}
    steps += 1
  end
rescue
  puts steps
end
