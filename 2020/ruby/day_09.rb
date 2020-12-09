N = 25

data = ARGF.read.scan(/\d+/).map(&:to_i)

i = (N..).find {|i|
  !data[i-N,N].combination(2).map(&:sum).include?(data[i])
}
invalid = data[i]

(0..).each do |start|
  (2..data.size-start-1).each do |len|
    sum = data[start, len].sum
    if sum == invalid
      p data[start, len].minmax.sum
      exit
    elsif sum > invalid
      next
    end
  end
end
