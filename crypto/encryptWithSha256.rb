#!/usr/bin/ruby

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

require 'base64'
require 'digest'

def encrypt(plainText)
  ##### Padding #####
  pd1 = 32 - ((plainText.length + 1) % 32)
  ptp1 = pd1.chr + plainText + (0.chr * pd1)
  sha256 = Digest::SHA256.new

  ##### Encryption (round 1) #####
  c1   = ''
  cPre = ''
  cCur = ''
  (0 .. ptp1.length-1).step(32) do |i|
    ptp1Bytes = Array.new
    ptp1[i .. i+31].each_byte do |b|
      ptp1Bytes.push(b)
    end
    shaBytes = Array.new
    sha256.digest(cPre + $passPhrase).each_byte do |b|
      shaBytes.push(b)
    end
    cCur = ''
    0.upto(31) { |j|
      cCur += (ptp1Bytes[j] ^ shaBytes[j]).chr
    }
    cPre = cCur
    c1  += cCur
  end

  ##### Encryption (round 2) #####
  c3   = ''
  cPre = ''
  cCur = ''
  cPre = sha256.digest(c1 + $passPhrase)
  c3  += cPre

  (0 .. c1.length-1).step(32) do |i|
    c1Bytes = Array.new
    c1[i .. i+31].each_byte do |b|
      c1Bytes.push(b)
    end
    shaBytes = Array.new
    sha256.digest(cPre + $passPhrase).each_byte do |b|
      shaBytes.push(b)
    end
    cCur = ''
    0.upto(31) { |j|
      cCur += (c1Bytes[j] ^ shaBytes[j]).chr
    }
    cPre = cCur
    c3  += cCur
  end

  return c3
end

def decrypt(cipherText)
  c3 = Base64.decode64(cipherText)
  sha256 = Digest::SHA256.new

  ##### Decryption #####
  ptp3 = ''
  pPre = ''
  pCur = ''
  dPre = ''
  dCur = ''
  dCurBytes = Array.new
  (0 .. c3.length-32-1).step(32) do |i|
    if ($i == 0)
      dCur = sha256.digest($passPhrase)
    else
      pPreBytes = Array.new
      pPre.each_byte do |b|
        pPreBytes.push(b)
      end
      dPreBytes = Array.new
      dPre.each_byte do |b|
        dPreBytes.push(b)
      end
      dpXorStr = ''
      0.upto(dPreBytes.length-1) { |j|
        dpXorStr += (pPreBytes[j] ^ dPreBytes[j]).chr
      }
      dCur = sha256.digest(dpXorStr + $passPhrase)
      dCurBytes = Array.new
      dCur.each_byte do |b|
        dCurBytes.push(b)
      end
    end
    c3Bytes = Array.new
    c3[i+32 .. i+32+31].each_byte do |b|
      c3Bytes.push(b)
    end
    shaBytes = Array.new
    sha256.digest(c3[i .. i+31] + $passPhrase).each_byte do |b|
      shaBytes.push(b)
    end
    pCur = ''
    0.upto(dCurBytes.length-1) { |j|
      pCur += (c3Bytes[j] ^ shaBytes[j] ^ dCurBytes[j]).chr
    }
    dPre  = dCur
    pPre  = pCur
    ptp3 += pCur
  end

  ##### Unpadding #####
  pd3 = ptp3[0].ord
  pt3 = ptp3[1 .. ptp3.length-1]
  pt3 = pt3[0 .. pt3.length-pd3-1]

  return pt3
end

if (ARGV.length < 1)
  print "\n  Usage: #{$0} -d|-e\n\n"
  exit(1)
end

mode = ARGV[0]

system "stty -echo"
print "Passphrase: "
$passPhrase = STDIN.gets.chomp
puts
system "stty echo"

if (mode == '-e')
  print "Plaintext: "
  pt = STDIN.read
  print Base64.encode64(encrypt(pt))
elsif (mode == '-d')
  print "Ciphertext: "
  ct = STDIN.read
  print decrypt(ct)
end

exit(0)

