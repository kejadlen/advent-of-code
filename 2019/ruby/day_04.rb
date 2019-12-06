# typed: strict
puts (236491..713787).map(&:to_s).count {|password|
  matching_digits = password.scan(/(.)\1/)

  !matching_digits.empty? && matching_digits.flatten.any? {|d| !password.include?(d * 3) } && password.chars.each_cons(2).all? {|a,b| a <= b }
}
