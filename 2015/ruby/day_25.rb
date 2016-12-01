row = 2981
col = 3075

i = row*(row-1)/2 + 1
i += (row..row+col-1).inject(:+) - row

value = 20151125
(i-1).times do
  value *= 252533
  value %= 33554393
end
puts value

__END__
Enter the code at row 2981, column 3075.
