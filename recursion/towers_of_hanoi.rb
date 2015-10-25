#!/usr/bin/ruby

# Written by Bill Brassfield in 2014

#
# This program uses recursion to demonstrate how the stone blocks
# in a tower of height n can be moved to another column according
# to the simple rule (no block may be placed on top of a smaller
# block).  The number of moves required is 2-to-the-n power minus
# one.  Anything with n >= 10 will generate over 1,000 lines of
# output, roughly doubling for each increment of n.
#

if ((ARGV.length != 1) || (ARGV.first !~ /^\d+$/) || (Integer(ARGV.first) > 20))
  print "\n  Usage: #{$0} n\n\n  (where n is the tower height; n in [1 .. 16] is best)\n\n"
  exit(1)
end

order = Integer(ARGV.first)

$towers = Array.new()
$t0 = Array.new();  $t1 = Array.new();  $t2 = Array.new()
$towers.push($t0);  $towers.push($t1);  $towers.push($t2)

$fromToMap = Hash["01" => 2, "10" => 2, "02" => 1, "20" => 1, "12" => 0, "21" => 0]

$count = 0;  $padTo = 22

if (order > 10)
  $padTo += 3*(order - 10)
end

order.downto(1) { |i| $t0.push(i) }

def move(from, to, height)
  if (height == 1)
    $towers[to].push($towers[from].pop)
    showStatus()
    $count += 1
  else
    newTo = $fromToMap[from.to_s + to.to_s]
    move(from, newTo, height - 1)
    move(from, to, 1)
    move(newTo, to, height - 1)
  end
end

def showStatus
  s1 = "[" + $t0.join(',') + "]"
  s2 = "[" + $t1.join(',') + "]"
  s3 = "[" + $t2.join(',') + "]"
  z1 = " " * ($padTo - s1.length)
  z2 = " " * ($padTo - s2.length)
  puts s1 + z1 + "     " + s2 + z2 + "     " + s3
end

showStatus()
move(0, 2, order)
puts "order = " + order.to_s + ", number of moves = " + $count.to_s

