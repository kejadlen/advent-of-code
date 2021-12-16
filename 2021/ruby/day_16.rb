require "strscan"

Packet = Struct.new(:version, :type_id, :content) do
  include Enumerable

  def self.parse(ss)
    version = ss.scan(/.{3}/).to_i(2)
    type_id = ss.scan(/.{3}/).to_i(2)

    case type_id
    when 4 # literal value
      value = ss.scan(/(1.{4})*(0.{4})/).chars
        .each_slice(5).flat_map { _1[1..4] }.join
        .to_i(2)
      Literal.new(version, type_id, value)
    else # operator
      sub_packets = case
                    when ss.scan(/0(.{15})/)
                      length = ss.captures[0].to_i(2)
                      sub_packet = ss.scan(/.{#{length}}/)

                      sss = StringScanner.new(sub_packet)
                      sub_packets = []
                      until sss.eos?
                        sub_packets << parse(sss)
                      end
                      sub_packets
                    when ss.scan(/1(.{11})/)
                      n = ss.captures[0].to_i(2)
                      n.times.map { parse(ss) }
                    else
                      fail
                    end
      Operator.new(version, type_id, sub_packets)
    end
  end

  def each
    return enum_for(__method__) unless block_given?

    yield self
  end
end

class Literal < Packet
  def value = content
end

class Operator < Packet
  def each(&block)
    super

    content.each do |sub_packet|
      sub_packet.each(&block)
    end
  end

  def value
    values = content.map(&:value)
    case type_id
    when 0 then values.sum
    when 1 then values.inject(:*)
    when 2 then values.min
    when 3 then values.max
    when 4 then fail
    when 5 then values.inject(:>) ? 1 : 0
    when 6 then values.inject(:<) ? 1 : 0
    when 7 then values.inject(:==) ? 1 : 0
    else        fail
    end
  end
end

message = ARGF.read.chomp.chars.map { _1.to_i(16).to_s(2).rjust(4, ?0) }.join
ss = StringScanner.new(message)
packet = Packet.parse(ss)

p packet.sum(&:version)
p packet.value
