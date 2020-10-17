#!/usr/bin/perl
use warnings;
use strict;
my $regex = qr/([a-zA-Z_]+)\=\{\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+)\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+) \}/mp;
open(FH, '<', $ARGV[0]) or die $!;

while(<FH>){
   my @array = $_ =~ /$regex/g;
   if (@array) { print $array[0] . ";" . $array[1]  . ";" . $array[2]   . ";" . $array[3] . ";\n"; }
}
close(FH);
