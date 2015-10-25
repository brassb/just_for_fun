#!/usr/bin/ruby

# Written by Bill Brassfield in 2015

# Calculates arbitrary-precision square root of any positive number
#
# Usage:
#
#   ./sqrt.rb number [number-of-digits]
#
#   (default number-of-digits is 101)

require 'bigdecimal'

if (ARGV.length == 0)
  puts "\n  Usage: $0 number [number-of-digits]\n\n"
  puts "    (the default number-of-digits is 101)\n\n"
  exit(1)
end

numberOfDigits = "101"
if ((ARGV.length >= 2) && (ARGV[1] =~ /^\d+$/))
  numberOfDigits = ARGV[1]
end

prec    = numberOfDigits.to_i
prec3   = prec + 3
prec5   = prec + 5
num     = BigDecimal::new(ARGV[0])
sr      = BigDecimal::new("1")       # initial guess for square root
one     = BigDecimal::new("1")
two     = BigDecimal::new("2")
epsilon = BigDecimal::new("1.0E-" + prec3.to_s)

srold = 0
i = 0
while (sr.sub(srold, prec5).abs > epsilon) do
  i += 1
  srold = sr
  sr = sr.add(num.div(sr, prec5), prec5).div(two, prec5)
  # puts sr.to_s("F")
  if (i > 50)  # In the event it doesn't converge...
    puts "Looping too much -- ending!"
    exit(0)
  end
end

# puts "#####################"

sr = sr.mult(one, prec)
puts sr.to_s("F")

