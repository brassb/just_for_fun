#!/usr/bin/perl -w

# Written by Bill Brassfield in 2015

#
# DISCLAIMER: This code is just for fun and learning ONLY!
# _DO_NOT_ use this code for any gaming/gambling activities
# where real money is at stake!
#

use strict;

use Digest::MD5 qw(md5_hex);

my %suits = (
  1 => 'Spades',
  2 => 'Diamonds',
  3 => 'Hearts',
  4 => 'Clubs'
);

my %values = (
   1 => 'Ace',
   2 => '2',
   3 => '3',
   4 => '4',
   5 => '5',
   6 => '6',
   7 => '7',
   8 => '8',
   9 => '9',
  10 => '10',
  11 => 'Jack',
  12 => 'Queen',
  13 => 'King'
);

#
# The contents of the "here document" populating the $secret variable
# is the output of:
#
#   dd if=/dev/urandom bs=1024 count=1 | mimeEncode
#
#   (mimeEncode is a Base64-encoder utility in my "tools" repository)
#
# For better randomness, new data from /dev/urandom should be used to
# populate the $secret variable each time this script runs.  But I chose
# not to do this, so that the same "random text" typed in would generate
# the same shuffled deck.

# NOTE:  This is just for fun and learning -- this code should NEVER be
# used in any gaming/gambling situations where real money is at stake.
# The main thing to observe in the output of this program is that even
# the tiniest change in the "random text" (just 1 bit) will create an
# "avalanche effect" in the SHA-256 hashing used internally, resulting
# in a very differently shuffled deck.
#

my $secret = <<MY_SECRET;
oNIrMCHUc2iunLYPFtGComCbG2+3AjTFplqO0RskcfasPLuh2QaUGEcxwA6SYXgHletAbWvBcNWh
aPgTRhYvCXXaLdAmYRYwjCu8+h1RFDlIiksE9Ixc8rPsaLx9YJdGJAZGHezVGmvAQ5gICjdKEbYI
2T5fUSsXhk0j+uHj69X7T73bWXpEpqqTfzMjLUA3yvBvjBQk/rV1OC4Jl5DK52fHrdv3u7dYnMX+
YvEETZgEirLqQXJeA8Sc3Sg0zi7VVu8J45MbjBiyIojNAfyYQv78JFHqsd4/39N7KrbcDCcskeR1
Q5Ugrgk0v4lDFuR6Z49nJA2rihwGbZl7RCTShGY835MNSkOFGdyzJkUUTSbH5AMeHX9v4Ng8Fx6s
iBHZPt6+fRnA4rxfwrtMOX4v6/P9q80HufOiolR1zZbe0ZLVSJIRLY8FIsaKOPuP59rdh3pZbtRD
FXcPQkmw4jywPZlg1zUG8VbEXsF5I7Zc4iYz02Hrtji/XQcJMFYzmZiQvjSDH1NiueVUW6kkp0rA
yBcAkk3076rrujFS5aAqAYEiJddmqwLTu1KKQad394Tdsl62Cnt5TrwQQKV3X0S3Lw18li5wIof+
A0a8ldqktgYcpGVofWWtzu614L3pV/bfrcTtdIfhjT98V8Gr3oOfhC+yNz+sIl/WF0a3Hy02gYoH
MDV5e9Ef6VTSchRkDv8E2TkeI8YoyGeZ6V+augZ6cbvKGlQ0aZk4ys7zkiH9Ica293bvK0Tgl0xZ
uhoKFPpD/LXQl35NyDmC2taodCYn6OzxqU19jMzOmc6KL975H1gbMVL+7eQ0RG/P1t6o07qpNBLt
8hJtkZ3OwM8mg5lBqId+efjk8D9qM/KzC/R8JZBy4vsaVr0XVShN+2sRVUh4w+vHS8e1Jt+29Lq3
mUyIhHSQwCl4UWmvqYuALhuZxrr8tpBqoLE7SYFr5T7mgyRGnVdFxjIT8T1EdhI655ETmBVo4SzE
7D72I6m+Ak41/HX5uqfc8fvc3o21AtQ1vWIZVRWy5DNan7Oaq7lsLvQKl76giUmzfVXV1kxMb5lb
hS3dHr2D/0XJmQ9lHvn/X6V8R/Y2fn14FT3VFBVTEBzQZp5HrwYBb1wdF0Hi/zzx0XTmsGVy5cp3
fx3KIWjpvUGHXsY7ZA0cw+ZxvXPfhn44mcwWJDkWQl2uIEVkHEiHLxxThRIBSLMuPOyMQSxj6iQu
BPpKRSHifhYKLG4cDl36oj+PFcHTsA40+H37aHQcCuk86mblkwcShRMe359VihJ6ItsWlzs13qa9
CEkS5aBKMx3igvQMy7/JECmmn4/EE1+hlEoog+1FH4VJO0OAIkrkaRzldgsinnIoS9wPdukJAA==
MY_SECRET

my $input;
if (scalar(@ARGV) == 1)
{
  $input = $ARGV[0];
}
else
{
  $|++;
  print "Enter some random text: ";
  $input = <STDIN>;
  chomp $input;
  $|--;
}

my $cards = {};
my $stuff = '{' . $secret . '} ' . $input . ' {' . $secret . '}';

for (my $j=1; $j<=4; $j++)
{
  for (my $i=1; $i<=13; $i++)
  {
    $stuff = md5_hex($stuff);
    $cards->{$stuff}->{'suit'}  = $j;
    $cards->{$stuff}->{'value'} = $i;
    $stuff .= '{' . $input . '}' . $secret . '{' . $j . '}' . $secret . '{' . $i . '}';
  }
}

foreach my $hash (sort keys %$cards)
{
  my $suit  = $suits{$cards->{$hash}->{'suit'}};
  my $value = $values{$cards->{$hash}->{'value'}};
  my $spc1 = " " x (5 - length($value));
  print "$value$spc1 of $suit\n";
}
