#!/usr/bin/perl -w

# Written by Bill Brassfield in 2015

#
# This was just a fun little exercise in trying to "securely" encrypt
# data using only SHA-256 hashing as the "bit-mixing blender".  Any
# change in either the plaintext or the passphrase (as small as 1 bit)
# will scramble the entire ciphertext (pseudo-randomly flipping about
# half of the bits), so it should (hopefully) be able to withstand a
# known-plaintext attack and differential cryptanalysis.  However, no
# investment of time, energy, or money has been spent by qualified
# cryptologists to determine the strength of this algorithm.  It may
# contain one or more serious weaknesses, making your sensitive data
# vulnerable to discovery.
#
# One really obvious disadvantage to using this algorithm is that the
# ciphertext is larger than the plaintext -- unlike commonly-used
# block-ciphers (like 3DES or Blowfish or AES), additional information
# needed for decryption gets padded into the ciphertext.
#
# DISCLAIMER: This is NOT to be considered a trusted crypto utility or
# algorithm for use in any environment where sensitive data is stored,
# processed, and/or transmitted.  This includes but is not limited to
# financial transactions, protection of classified information or trade
# secrets, or anything related to PCI or HIPAA compliance.  If you need
# to use strong cryptography, please use well-known, established, time-
# tested algorithms and implementations.  At the time of this writing,
# these might include 4096-bit RSA public/private key encryption, AES-256
# symmetric-key encryption (with CBC-mode and IV), with implementations
# in utilities/libraries such as OpenSSL or GPG.  Be sure to keep aware
# of advances in cryptanalysis, highly-parallel computing (including
# "quantum computing") before choosing a crypto algorithm/implementation
# for your environment.
#

use strict;

use Digest::SHA qw(sha256 sha256_hex sha256_base64);
use MIME::Base64;

sub encrypt($);
sub decrypt($);

if (scalar(@ARGV) < 1)
{
  die "\n  Usage: $0 -d|-e\n\n";
}

my $mode = shift(@ARGV);
my $pt;
my $ct;

$|++;

system "stty -echo";
print "Passphrase: ";
my $passPhrase = <STDIN>;
chomp $passPhrase;
print "\n";
system "stty echo";

if ($mode eq '-e')
{
  print "Plaintext: ";
  while ($_ = <STDIN>)
  {
    $pt .= $_;
  }
}
elsif ($mode eq '-d')
{
  print "Ciphertext (base64 encoded): ";
  while ($_ = <STDIN>)
  {
    $ct .= $_;
  }
}

$|--;

if ($mode eq '-e')
{
  print encode_base64(encrypt($pt));
}
elsif ($mode eq '-d')
{
  print decrypt($ct);
}

exit(0);

sub encrypt($)
{
  my $plainText = shift;

  ##### Padding #####

  my $pd1 = 32 - ((length($plainText) + 1) % 32);
  # my $pd2 = 32 - ((length($pt2) + 1) % 32);

  my $ptp1 = chr($pd1) . $plainText . (chr(0) x $pd1);
  # my $ptp2 = chr($pd2) . $pt2 . (chr(0) x $pd2);

  my $d1 = sha256($passPhrase);

  ##### Encryption (round 1) #####

  my $c1   = '';
  # my $c2   = '';

  my $cPre = '';
  my $cCur = '';
  for (my $i=0; $i<length($ptp1); $i+=32)
  {
    $cCur = substr($ptp1, $i, 32) ^ sha256($cPre . $passPhrase);
    $cPre = $cCur;
    $c1 .= $cCur;
  }

  ##### Encryption (round 2) #####

  my $c3 = '';

  $cPre = '';
  $cCur = '';
  $cPre = sha256($c1 . $passPhrase);
  $c3 .= $cPre;
  for (my $i=0; $i<length($c1); $i+=32)
  {
    $cCur = substr($c1, $i, 32) ^ sha256($cPre . $passPhrase);
    $cPre = $cCur;
    $c3 .= $cCur;
  }

  return $c3;
}

sub decrypt($)
{
  my $cipherText = shift;

  my $c3 = decode_base64($cipherText);

  ##### Decryption #####

  my $ptp3 = '';

  my $pPre = '';
  my $pCur = '';
  my $dPre = '';
  my $dCur = '';
  for (my $i=0; $i<length($c3)-32; $i+=32)
  {
    if ($i == 0)
    {
      $dCur = sha256($passPhrase);
    }
    else
    {
      $dCur = sha256(($pPre ^ $dPre) . $passPhrase);
    }
    $pCur = substr($c3, $i+32, 32) ^ sha256(substr($c3, $i, 32) . $passPhrase) ^ $dCur;
    $dPre = $dCur;
    $pPre = $pCur;
    $ptp3 .= $pCur;
  }

  ##### Unpadding #####

  my $pd3 = ord(substr($ptp3, 0, 1));
  my $pt3 = substr($ptp3, 1);
  $pt3 = substr($pt3, 0, length($pt3) - $pd3);

  return $pt3;
}

