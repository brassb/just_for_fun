#!/usr/bin/ruby

# Written by Bill Brassfield in 2015

# Calculates arbitrary-precision cube root of any positive number
#
# Usage:
#
#   ./cbrt.rb number [number-of-digits]
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
cr      = BigDecimal::new("1")       # initial guess for cube root
one     = BigDecimal::new("1")
two     = BigDecimal::new("2")
three   = BigDecimal::new("3")
epsilon = BigDecimal::new("1.0E-" + prec3.to_s)

crold = 0
i = 0
while (cr.sub(crold, prec5).abs > epsilon) do
  i += 1
  crold = cr
  cr = cr.add(cr, prec5).add(num.div(cr, prec5).div(cr, prec5), prec5).div(three, prec5)
  # puts cr.to_s("F")
  if (i > 50)  # In the event it doesn't converge...
    puts "Looping too much -- ending!"
    exit(0)
  end
end

# puts "#####################"

cr = cr.mult(one, prec)
puts cr.to_s("F")

