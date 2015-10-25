#!/usr/bin/perl -w

# Written by Bill Brassfield in 2015
# This program generates odd-ordered magic squares (3x3 through 31x31)

use strict;

my $size = $ARGV[0];
if (!defined($size) || ($size !~/^\d+$/) || ($size < 3) || ($size > 31) || ($size % 2 == 0))
{
  die "\n  Usage: $0 <odd-number-from-3-to-31>\n\n";
}

my $msq  = [];
for (my $i=0; $i<$size; $i++)
{
  my $row = [];
  for (my $j=0; $j<$size; $j++)
  {
    push(@$row, undef);
  }
  push(@$msq, $row);
}

my $xPos = ($size - 1) / 2;
my $yPos = 0;
for (my $i=1; $i<=$size*$size; $i++)
{
  $msq->[$yPos]->[$xPos] = $i;

  $xPos++;
  $yPos--;

  if (($xPos >= $size) && ($yPos < 0))
  {
    $xPos--;
    $yPos++;  $yPos++;
  }
  elsif (($xPos >= $size) && ($yPos >= 0) && ($yPos < $size))
  {
    $xPos = 0;
  }
  elsif (($yPos < 0) && ($xPos >= 0) && ($xPos < $size))
  {
    $yPos = $size - 1;
  }
  elsif (defined($msq->[$yPos]->[$xPos]))
  {
    $xPos--;
    $yPos++;  $yPos++;
  }
}

for ($yPos=0; $yPos<$size; $yPos++)
{
  for ($xPos=0; $xPos<$size; $xPos++)
  {
    printf(" %3d ", $msq->[$yPos]->[$xPos]);
  }
  print "\n";
}
