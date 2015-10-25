#!/usr/bin/perl -w

# Written by Bill Brassfield in 2014

#
# This program uses recursion to demonstrate how the stone blocks
# in a tower of height n can be moved to another column according
# to the simple rule (no block may be placed on top of a smaller
# block).  The number of moves required is 2-to-the-n power minus
# one.  Anything with n >= 10 will generate over 1,000 lines of
# output, roughly doubling for each increment of n.
#

use strict;

sub move($$$);
sub showStatus();

if ((scalar(@ARGV) != 1) || ($ARGV[0] !~ /^\d+$/) || (int($ARGV[0]) > 20)) {
  die "\n  Usage: $0 n\n\n  (where n is the tower height; n in [1 .. 16] is best)\n\n";
}
my $order = $ARGV[0];
my ($t0, $t1, $t2) = ([], [], []);
my $towers = [$t0, $t1, $t2];
my %fromToMap = (
  '01' => 2, '10' => 2,
  '02' => 1, '20' => 1,
  '12' => 0, '21' => 0
);
my $count = 0;
my $padTo = 22;
if ($order > 10) { $padTo += 3*($order - 10); }

for (my $i=$order; $i>=1; $i--) {
  push(@{$towers->[0]}, $i);
}
showStatus();
move(0, 2, $order);
print "order = $order, number of moves = $count\n";

sub move($$$) {
  my ($from, $to, $height) = (shift, shift, shift);

  if ($height == 1) {
    push(@{$towers->[$to]}, pop(@{$towers->[$from]}));
    showStatus();
    $count++;
  } else {
    my $newTo = $fromToMap{"$from$to"};
    move($from,  $newTo, $height - 1);
    move($from,  $to,    1);
    move($newTo, $to,    $height - 1);
  }
}

sub showStatus() {
  my $s1 = '[' . join(',', @{$towers->[0]}) . ']';
  my $s2 = '[' . join(',', @{$towers->[1]}) . ']';
  my $s3 = '[' . join(',', @{$towers->[2]}) . "]";
  my $z1 = " " x ($padTo - length($s1));
  my $z2 = " " x ($padTo - length($s2));
  print "$s1$z1     $s2$z2     $s3\n";
}
