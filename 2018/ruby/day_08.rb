class Node
  def self.from(raw)
    child_count = raw.shift
    metadata_count = raw.shift

    children = child_count.times.map { Node.from(raw) }
    metadata = metadata_count.times.map { raw.shift }

    Node.new(children, metadata)
  end

  def initialize(children, metadata)
    @children, @metadata = children, metadata
  end

  def checksum
    @metadata.sum + @children.map(&:checksum).sum
  end

  def value
    if @children.empty?
      @metadata.sum
    else
      @metadata.flat_map {|index|
        @children.fetch(index-1, [])
      }.map(&:value).sum
    end
  end
end

raw = ARGF.read.chomp.split(/\s+/).map(&:to_i)
root = Node.from(raw)
p root.value
