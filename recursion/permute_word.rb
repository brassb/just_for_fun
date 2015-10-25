#!/usr/bin/ruby

# Written by Bill Brassfield in 2014

#
# This program demonstrates the use of recursion to show all
# permutations of the letters in a word given as an argument
# on the command-line.
#
# NOTE: For words with 7 or more letters, the output will be quite
# large (with the number of output lines being N-factorial, where
# N is the number of letters).
#

if (ARGV.length != 1)
  print "\n  Usage: #{$0} word_to_permute\n\n"
  exit(1)
end

$list = ARGV[0].split(//)

def permute(order)
  if (order == 1)
    puts $list.join('')
  elsif (order == 2)
    puts $list.join('')
    swap($list.length - 1, $list.length - 2)
    puts $list.join('')
    swap($list.length - 1, $list.length - 2)
  else
    (order-1).downto(1) { |i|
      permute(order - 1)
      swap($list.length - i, $list.length - order)
    }
    permute(order - 1)
    (order-1).downto(1) { |i|
      swap($list.length - i, $list.length - 1 - i)
    }
  end
end

def swap(i1, i2)
  tmp = $list[i1]
  $list[i1] = $list[i2]
  $list[i2] = tmp
end

permute($list.length)
