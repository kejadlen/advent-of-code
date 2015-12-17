class String
  REQUIRED_SUBSTRING = (?a..?z).each_cons(3).map(&:join)
  PAIRS = (?a..?z).map {|c| c*2 }

  def password?
    REQUIRED_SUBSTRING.any? {|s| self.include?(s) } &&
      self !~ /[iol]/ &&
      PAIRS.count {|p| self.include?(p) } >= 2
  end
end

seed = "cqjxxyzz"
while true
  seed = seed.succ
  break if seed.password?
end
puts seed
