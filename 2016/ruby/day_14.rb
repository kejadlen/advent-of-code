require 'digest/md5'

class Keys
  attr_reader :seed, :hash

  def initialize(seed)
    @seed = seed
    @hash = Hash.new {|h,k|
      hash = Digest::MD5.hexdigest("#{seed}#{k}")
      2016.times do
        hash = Digest::MD5.hexdigest(hash)
      end
      h[k] = hash
    }
  end

  def each
    return enum_for(__method__) unless block_given?

    (0..Float::INFINITY).each do |index|
      next unless /(.)\1\1/ =~ hash[index]

      needle = $1 * 5
      stream = (1..1000).map {|i| hash[index + i] }
      next unless stream.any? {|h| h.include?(needle) }

      yield [index, hash[index]]
    end
  end
end

keys = Keys.new('qzyelonm')
p keys.each.take(64).last
