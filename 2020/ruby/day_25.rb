def transform(subject_number)
  return enum_for(__method__, subject_number) unless block_given?

  value = 1
  (0..).each do |loop_size|
    yield [loop_size, value]
    value *= subject_number
    value %= 20201227
  end
end

public_keys = ARGF.read.scan(/\d+/).map(&:to_i)

loop_size, _ = transform(7).find {|_,v| v == public_keys.first }
_, encryption_key = transform(public_keys.last).find {|i,_| i == loop_size }

p encryption_key
