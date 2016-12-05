require 'digest/md5'

door_id = 'wtnhxymk'
password = Array.new(8, nil)

VALID = (0..7).map(&:to_s).to_a

index = 0
while password.any?(&:nil?)
  puts index if index % 1000000 == 0
  hash = Digest::MD5.hexdigest("#{door_id}#{index}")
  if hash.start_with?('00000')
    i = hash[5]
    if VALID.include?(i) && password[i.to_i].nil?
      password[i.to_i] = hash[6]
      p hash, password
    end
  end
  index += 1
end

puts password.join
