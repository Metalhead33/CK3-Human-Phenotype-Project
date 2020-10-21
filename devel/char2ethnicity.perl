#!/usr/bin/perl
use warnings;
use strict;
use List::Util qw[min max];
use POSIX qw[ceil floor];

my $filename = $ARGV[0];
my $regex = qr/([a-zA-Z_]+)\=\{\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+)\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+) \}/mp;
open(FH, '<', $filename) or die $!;

my $marginOfError = 0.05;
my $coarse = 20.0;

sub round {
	my $p1 = shift;
	return floor($p1+0.5);
}
sub createRangeA {
	my $p1 = shift;
	$p1 = $p1 / 255.0;
	my $a = round(max(min($p1-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b = round(max(min($p1+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	printf("%.2f %.2f",$a, $b);
}
sub createRangeB {
	my $p1 = shift;
	my $p2 = shift;
	$p1 = $p1 / 255.0;
	$p2 = $p2 / 255.0;
	my $a1 = round(max(min($p1-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b1 = round(max(min($p1+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $a2 = round(max(min($p2-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b2 = round(max(min($p2+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	printf("%.2f %.2f %.2f %.2f",$a1, $a2, $b1, $b2); 
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
delete($data{'face_detail_cheek_fat'});

my $racename = substr($filename, 0, -4);
$racename =~ s/\//\_/d;
$racename =~ s/\-/\_/d;
$racename =~ s/advanced_//d;
my $key;
print "$racename = {\n\ttemplate = \"ethnicity_template\"\n";
foreach $key (keys %data)
{
	print "\t$key  = {\n\t\t";
	# do whatever you want with $key and $value here ...
	my $value = $data{$key};
	my $xval = $value->{'xVal'};
	my $yval = $value->{'yVal'};
	if( ($key eq 'skin_color') || ($key eq 'eye_color') || ($key eq 'hair_color') ) {
	print "10 = { ";
	createRangeB($xval,$yval);
	print " }";
	} else {
	print "10 = { name = $xval range = { ";
	createRangeA($yval);
	print " } }";
	}
	print "\n\t}\n";
}
print "\n}\n";

close(FH);
