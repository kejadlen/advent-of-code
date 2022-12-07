input = ARGF.read.lines(chomp: true)

Dir = Struct.new(:parent, :name, :children) do
  def size = children.sum(&:size)

  def each
    return enum_for(__method__) unless block_given?

    yield self

    children.each do |child|
      case child
      when Dir
        child.each { yield _1 }
      when File
        yield child
      else
        fail child.inspect
      end
    end
  end
end

File = Struct.new(:parent, :name, :size)

root = Dir.new(nil, ?/, [])
pwd = root

input.each do |line|
  case line
  when /\$ cd \//
    # no-op
  when /\$ cd \.\./
    pwd = pwd.parent
  when /\$ cd (.+)/
    pwd = pwd.children.find { _1.name == $1 }
  when /\$ ls/
    # no-op
  when /dir (.+)/
    pwd.children << Dir.new(pwd, $1, [])
  when /(\d+) (.+)/
    pwd.children << File.new(pwd, $2, $1.to_i)
  else
    fail line
  end
end

# part 1
p root.each
  .select { Dir === _1 }
  .map(&:size)
  .select { _1 < 100_000 }
  .sum

# part 2
p root.each
  .select { Dir === _1 }
  .map(&:size)
  .sort
  .find { _1 >= 30_000_000 - (70_000_000 - root.size) }

