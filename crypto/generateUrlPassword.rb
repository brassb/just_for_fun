#!/usr/bin/ruby

# Written by Bill Brassfield in 2014

#
# A technically non-random but interesting and fun way to generate
# secure passwords for your online accounts.  (It's "secure" as long
# as your Master Password is secure.  For added security, the Serial
# Number doesn't have to be numeric -- it can be any string, so feel
# free to use your own secret serial-numbering scheme to come up with
# new/updated passwords.)  Also, you might want to append your account's
# username and/or e-mail address to the end of the URL (or put it at
# the beginning before the URL).  Whatever you come up with, just be
# consistent so you won't forget how to regenerate your password if
# you forget it.
#

require 'digest'
require 'base64'

print "URL: "
url = STDIN.gets.chomp

print "Master Password: "
system "stty -echo"
masterPass = STDIN.gets.chomp
system "stty echo"
puts

print "Serial #: "
serial = STDIN.gets.chomp

print "Use Special Characters? "
useSpecialChars = STDIN.gets.chomp

print "Password Length (up to 24 chars) [16]: "
passLen = STDIN.gets.chomp
if (passLen =~ /^\s*$/)
  passLen = 16
else
  passLen = Integer(passLen)
end

regularChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+'
specialChars = <<'SPECIAL_CHARS'
`~!@#$%^&*()-_=?[{]}\|;:'",<.>/+
SPECIAL_CHARS
specialChars = specialChars.chomp
regToSymMap = Hash.new()
regularArr = regularChars.split(//)
specialArr = specialChars.split(//)
0.upto(63) { |i|
  regToSymMap[regularArr[i]] = specialArr[i % 32]
}
regToSymMap['='] = '='

sha256 = Digest::SHA256.new

firstPacked  = sha256.digest(url + " " + masterPass + " " + serial + "\n")
# firstHash    = firstPacked.unpack("H*").first
firstHash    = Digest::hexencode(firstPacked)
secondPacked = sha256.digest(firstHash + " " + masterPass + " " + serial + "\n")
 
encoded = Base64.encode64(firstPacked)
encoded = encoded.gsub(/\n/, "")

posMap   = Hash.new()
posCount = 0

secondPacked.split(//).each do |ch|
  pos = ch.ord
  if (pos > 251)
  else
    pos = pos % 42
    if (defined?(posMap[pos]) && posMap[pos] == 1)
    else
      posMap[pos] = 1
      posCount += 1
    end
    if (posCount >= 14)
      break
    end
  end
end

encArr = Array.new()

if (useSpecialChars =~ /^\s*(Y|y|1)\s*$/)
  encArr = encoded.split(//)
  0.upto(encArr.length - 1) { |i|
    if (defined?(posMap[i]) && (posMap[i] == 1))
      encArr[i] = regToSymMap[encArr[i]]
    end
  }
else
  encoded = encoded.gsub(/[^A-Za-z0-9]/, '')
  encArr = encoded.split(//)
end

password = encArr[0 .. (passLen-1)].join('')

puts
puts password
puts

