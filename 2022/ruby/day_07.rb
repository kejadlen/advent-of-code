input = ARGF.read.lines(chomp: true).slice_when { _2.start_with?(?$) }

Dir = Struct.new(:parent, :name, :children) do
  include Enumerable

  def size = children.sum(&:size)

  def each(&block)
    return enum_for(__method__, &block) unless block

    block.(self)

    children.each do |child|
      case child
      when Dir
        child.each(&block)
      when File
        block.(child)
      else
        fail child.inspect
      end
    end
  end
end

File = Struct.new(:parent, :name, :size)

root = Dir.new(nil, ?/, [])
pwd = root

input.each do |chunk|
  cmd, *out = *chunk
  case cmd
  when /\$ cd \//
    # no-op
  when /\$ cd \.\./
    pwd = pwd.parent
  when /\$ cd (.+)/
    pwd = pwd.children.find { _1.name == $1 }
  when /\$ ls/
    out.each do |line|
      case line
      when /(\d+) (.+)/
        pwd.children << File.new(pwd, $2, $1.to_i)
      when /dir (.+)/
        pwd.children << Dir.new(pwd, $1, [])
      else
        fail line
      end
    end
  else
    fail chunk.inspect
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

