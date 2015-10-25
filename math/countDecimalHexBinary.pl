#!/usr/bin/perl -w

# Written by Bill Brassfield in 2015

#
# Count from 0 to 255 in Decimal, Hex, and Binary.
# Mainly as an exercise of Perl's "unpack" built-in function.
#

use strict;

for (my $i=0; $i<=255; $i++)
{
  my $spc = "";
  if ($i < 100) { $spc .= " "; }
  if ($i <  10) { $spc .= " "; }
  my $binStr = unpack("B*", chr($i));
  my $hexStr = unpack("H*", chr($i));
  print "$spc$i   $hexStr   $binStr\n";
}
