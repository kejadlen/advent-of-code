require "strscan"

def parse(ss)
  version = ss.scan(/.{3}/).to_i(2)
  type_id = ss.scan(/.{3}/).to_i(2)

  content = case type_id
            when 4 # literal value
              value = ""
              while group = ss.scan(/1/)
                value << ss.scan(/.{4}/)
              end
              ss.scan(/0/)
              value << ss.scan(/.{4}/)
              value.to_i(2)
            else # operator
              length_type_id = ss.scan(/./)
              case length_type_id
              when ?0
                sub_packet_length = ss.scan(/.{15}/).to_i(2)
                sub_packet = ss.scan(/.{#{sub_packet_length}}/)

                sss = StringScanner.new(sub_packet)
                sub_packets = []
                until sss.eos?
                  sub_packets << parse(sss)
                end
                sub_packets
              when ?1
                sub_packet_num = ss.scan(/.{11}/).to_i(2)
                sub_packet_num.times.map { parse(ss) }
              else
                fail
              end
            end

  { version: version, type_id: type_id, content: content }
end

message = ARGF.read.chomp.chars.map { _1.to_i(16).to_s(2).rjust(4, ?0) }.join
ss = StringScanner.new(message)
packet = parse(ss)

def each(packet, &block)
  return enum_for(__method__, packet) unless block_given?

  block.(packet)
  if (content = packet.fetch(:content)).is_a?(Array)
    content.each do |sub_packet|
      each(sub_packet, &block)
    end
  end
end

# p each(packet).sum { _1.fetch(:version) }

value = {
  0 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.sum },
  1 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.inject(:*) },
  2 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.min },
  3 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.max },
  4 => ->(c) { c },
  5 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.inject(:>) ? 1 : 0 },
  6 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.inject(:<) ? 1 : 0 },
  7 => ->(c) { c.map { value.fetch(_1.fetch(:type_id)).(_1.fetch(:content)) }.inject(:==) ? 1 : 0 },
}

p value.fetch(packet.fetch(:type_id)).(packet.fetch(:content))
