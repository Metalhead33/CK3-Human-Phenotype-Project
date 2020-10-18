#!/usr/bin/perl
use warnings;
use strict;
use List::Util qw[min max];
use POSIX qw[ceil floor];

my $regex = qr/([a-zA-Z_]+)\=\{\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+)\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+) \}/mp;
open(FH, '<', $ARGV[0]) or die $!;

my $marginOfError = 0.05;
my $coarse = 20.0;

sub round {
	my $p1 = shift;
	return floor($p1+0.5);
}
sub createRange {
	my $p1 = shift;
	$p1 = $p1 / 255.0;
	my $a = round(max(min($p1-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b = round(max(min($p1+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	printf("%.2f %.2f",$a, $b);
}

my %data;

while(<FH>){
   my @array = $_ =~ /$regex/g;
   if (@array) {
	$data{$array[0]}{'xVal'} =  $array[1];
	$data{$array[0]}{'xVal'} =~ tr/\"//d;
	$data{$array[0]}{'yVal'} =  $array[2];
   }
}

delete($data{'expression_brow_wrinkles'});
delete($data{'expression_eye_wrinkles'});
delete($data{'expression_forehead_wrinkles'});
delete($data{'expression_other'});
delete($data{'complexion'});
delete($data{'gene_bs_body_type'});
delete($data{'gene_bs_body_shape'});
delete($data{'gene_bs_bust'});
delete($data{'gene_age'});
delete($data{'hairstyles'});
delete($data{'beards'});
delete($data{'teeth_accessory'});

my $key;
print "ethnicity = {\n\ttemplate = \"ethnicity_template\"\n";
foreach $key (keys %data)
{
	print "\t$key  = {\n\t\t";
	# do whatever you want with $key and $value here ...
	my $value = $data{$key};
	my $xval = $value->{'xVal'};
	my $yval = $value->{'yVal'};
	if( ($key eq 'skin_color') || ($key eq 'eye_color') || ($key eq 'hair_color') ) {
	print "10 = { ";
	createRange($xval);
	print " ";
	createRange($yval);
	print " }";
	} else {
	print "10 = { name = $xval range = { ";
	createRange($yval);
	print " } }";
	}
	print "\n\t}\n";
}
print "\n}\n";

close(FH);
