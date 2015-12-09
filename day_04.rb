require "digest/md5"

key = "ckczppom"
index = 1
# until Digest::MD5.hexdigest("#{key}#{index}").start_with?("00000")
until Digest::MD5.hexdigest("#{key}#{index}").start_with?("000000")
  index += 1
end
puts index
