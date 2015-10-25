#!/usr/bin/perl -w

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

use strict;

sub permute($);
sub swap($$$);

if (scalar(@ARGV) != 1) {
  die "\n  Usage: $0 word_to_permute\n\n";
}

my @list = split('', $ARGV[0]);
permute(scalar(@list));

sub permute($) {
  my $order = shift;

  if ($order == 1) {
    print join('', @list) . "\n";
  }
  elsif ($order == 2) {
    print join('', @list) . "\n";
    swap(\@list, $#list, $#list - 1);
    print join('', @list) . "\n";
    swap(\@list, $#list, $#list - 1);
  }
  else {
    for (my $i=$order-1; $i>=1; $i--) {
      permute($order - 1);
      swap(\@list, $#list - ($i - 1), $#list - ($order - 1));
    }
    permute($order - 1);
    for (my $i=$order-1; $i>=1; $i--) {
      swap(\@list, $#list - ($i - 1), $#list - $i);
    }
  }
}

sub swap($$$) {
  my ($ref, $i1, $i2) = (shift, shift, shift);

  my $tmp = $ref->[$i1];
  $ref->[$i1] = $ref->[$i2];
  $ref->[$i2] = $tmp;
}
