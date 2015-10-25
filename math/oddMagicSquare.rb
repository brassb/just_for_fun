#!/usr/bin/ruby

# Written by Bill Brassfield in 2015
# This program generates odd-ordered magic squares (3x3 through 31x31)

size = Integer(ARGV[0])

if ((size < 3) || (size > 31) || (size % 2 == 0))
  print "\n  Usage: <odd-number-from-3-to-31>\n\n"
  exit(1)
end

msq = Array.new(size, 0)
0.upto(size-1) { |i|
  msq[i] = Array.new(size, 0)
  0.upto(size-1) { |j|
    msq[i][j] = 0
  }
}

xpos = (size - 1) / 2
ypos = 0

1.upto(size*size) { |i|
  msq[ypos][xpos] = i

  xpos += 1;  ypos -= 1

  if ((xpos >= size) && (ypos < 0))
    xpos -= 1;  ypos += 2
  elsif ((xpos >= size) && (ypos >= 0) && (ypos < size))
    xpos = 0
  elsif ((ypos < 0) && (xpos >= 0) && (xpos < size))
    ypos = size - 1
  elsif (msq[ypos][xpos] != 0)
    xpos -= 1;  ypos += 2
  end
}


0.upto(size-1) { |i|
  0.upto(size-1) { |j|
    printf(" %3d ", msq[i][j])
  }
  puts
}
