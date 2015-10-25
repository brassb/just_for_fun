#!/usr/bin/perl -w

# Written by Bill Brassfield in 2014

#
# A technically non-random but interesting and fun way to generate
# secure passwords for your online accounts.  (It's "secure" as long
# as your Master Password is secure.  For added security, the Serial
# Number doesn't have to be numeric -- it can be any string, so feel
# free to use your own secret serial-numbering scheme to come up with
# new/updated passwords.)  Also, you might want to append your account's
# username and/or e-mail address to the end of the URL (or put it at
# the beginning before the URL).  Whatever you come up with, just be
# consistent so you won't forget how to regenerate your password if
# you forget it.
#

use strict;

use Digest::SHA qw(sha256 sha256_hex sha256_base64);
use MIME::Base64;

$|++;

my $defaultLength = 16;
my $maxPassLength = 24;

my $regularChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/+';

my $specialChars = <<'SPECIAL_CHARS';
`~!@#$%^&*()-_=?[{]}\|;:'",<.>/+
SPECIAL_CHARS
chomp $specialChars;

my @regularArr = split('', $regularChars);
my @symbolArr  = split('', $specialChars);

my %regToSymMap = ();
for (my $i=0; $i<64; $i++)
{
  $regToSymMap{$regularArr[$i]} = $symbolArr[$i % 32];
}
$regToSymMap{'='} = '=';

print "URL: ";
my $url = <STDIN>;
chomp $url;

system "stty -echo";
print "Master Password: ";
my $masterPass = <STDIN>;
chomp $masterPass;
system "stty echo";
print "\n";

print "Serial #: ";
my $serial = <STDIN>;
chomp $serial;

print "Use Special Characters? ";
my $useSpecialChars = <STDIN>;
chomp $useSpecialChars;

my $passwordLength = -1;

while (($passwordLength < 4) || ($passwordLength > $maxPassLength))
{
  print "Password Length (up to $maxPassLength chars) [$defaultLength]: ";
  $passwordLength = <STDIN>;
  chomp $passwordLength;

  if ($passwordLength =~ /^\s*$/s)
  {
    $passwordLength = $defaultLength;
  }
}

my $firstPacked  = sha256("$url $masterPass $serial\n");
my $firstHash    = unpack("H*", $firstPacked);
my $secondPacked = sha256("$firstHash $masterPass $serial\n");

my $encoded = encode_base64($firstPacked);
$encoded =~ s/\n//g;

print "\n";

my %posMap   = ();
my $posCount = 0;
foreach my $ch (split('', $secondPacked))
{
  my $pos = ord($ch);
  next if ($pos > 251);
  $pos = $pos % 42;
  if (!exists($posMap{$pos}))
  {
    $posMap{$pos} = 1;
    $posCount++;
  }
  last if ($posCount >= 14);
}

my @encArr;

if ($useSpecialChars =~ /^\s*(?:Y|1)\s*$/i)
{
  @encArr = split('', $encoded);

  for (my $i=0; $i<=$#encArr; $i++)
  {
    if (exists($posMap{$i}))
    {
      $encArr[$i] = $regToSymMap{$encArr[$i]};
    }
  }
}
else
{
  $encoded =~ s/[^A-Za-z0-9]//g;
  @encArr = split('', $encoded);
}

my $password = join('', @encArr[0 .. ($passwordLength-1)]);

print "$password\n\n";

