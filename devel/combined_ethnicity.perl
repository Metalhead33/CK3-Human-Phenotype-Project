#!/usr/bin/perl
use warnings;
use strict;
use List::Util qw[min max];
use POSIX qw[ceil floor];

my $filename = shift;
my $beautyFilename = shift;
my $height = shift;
$height = $height or 'MEDIUM';
my $regex = qr/([a-zA-Z_]+)\=\{\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+)\s+([\"a-zA-Z0-9_]+)\s+([a-zA-Z0-9]+) \}/mp;
open(FH, '<', $filename) or die $!;
open(BH, '<', $beautyFilename) or die $!;

my $const_marginOfError = 0.2;
my $const_coarse = 30.0;
my $const_beautyMarginOfError = 0.025;
my $const_beautyCoarse = 60.0;
my $const_SCmarginOfError = 0.05;
my $const_SCcoarse = 20.0;

sub round {
	my $p1 = shift;
	return floor($p1+0.5);
}
sub createRangeA {
	my $p1 = shift;
	my $marginOfError = shift;
	my $coarse = shift;
	$p1 = $p1 / 255.0;
	my $a = round(max(min($p1-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b = round(max(min($p1+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	printf("%.4f %.4f",$a, $b);
}
sub createRangeB {
	my $p1 = shift;
	my $p2 = shift;
	my $marginOfError = shift;
	my $coarse = shift;
	$p1 = $p1 / 255.0;
	$p2 = $p2 / 255.0;
	my $a1 = round(max(min($p1-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b1 = round(max(min($p1+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $a2 = round(max(min($p2-$marginOfError,1.0),0.0)*$coarse)/$coarse;
	my $b2 = round(max(min($p2+$marginOfError,1.0),0.0)*$coarse)/$coarse;
	printf("%.4f %.4f %.4f %.4f",$a1, $a2, $b1, $b2); 
}

my %data;
my %beautyData;

while(<FH>){
   my @array = $_ =~ /$regex/g;
   if (@array) {
	$data{$array[0]}{'xVal'} =  $array[1];
	$data{$array[0]}{'xVal'} =~ tr/\"//d;
	$data{$array[0]}{'yVal'} =  $array[2];
   }
}
while(<BH>){
   my @array = $_ =~ /$regex/g;
   if (@array) {
	$beautyData{$array[0]}{'xVal'} =  $array[1];
	$beautyData{$array[0]}{'xVal'} =~ tr/\"//d;
	$beautyData{$array[0]}{'yVal'} =  $array[2];
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
delete($data{'gene_height'});
delete($data{'eye_color'});
delete($data{'hair_color'});

my $racename = substr($filename, 0, -4);
$racename =~ s/\//\_/d;
$racename =~ s/\-/\_/d;
$racename =~ s/advanced_//d;
my $key;
my @a = (1..3);
print "$racename = {\n\ttemplate = \"ethnicity_template\"\n";
print("\teye_color = {\n\t\t# # Brown\n\t\t# 50 = { 0.05 0.7 0.35 1.0 }\n\t\t# Black\n\t\t50 = { 0.05 0.95 0.35 1.0 }\n\t}\n\thair_color = {\n\t\t# Blonde\n\t\t# 10 = { 0.25 0.2 0.75 0.55 }\n\t\t# Brown\n\t\t#2 = { 0.65 0.7 0.9 1.0 }\n\t\t# # Red\n\t\t# 10 = { 0.85 0.0 1.0 0.5 }\n\t\t# Black\n\t\t98 = { 0.01 0.9 0.5 0.99 }\n\t}");
if($height eq 'TALL') {
print "\n\tgene_height = {\n\t\t10 = { name = normal_height range = { 0.70 0.80 } }\n\t}\n"
} elsif($height eq 'MEDIUM') {
print "\n\tgene_height = {\n\t\t10 = { name = normal_height range = { 0.45 0.60 } }\n\t}\n"
} elsif($height eq 'SHORT') {
print "\n\tgene_height = {\n\t\t10 = { name = normal_height range = { 0.30 0.45 } }\n\t}\n"
} else {
print "\n\tgene_height = {\n\t\t10 = { name = normal_height range = { 0.45 0.60 } }\n\t}\n"
}
foreach $key (keys %data)
{
	print "\t$key  = {\n";
	my $value = $data{$key};
	my $beautyValue = $beautyData{$key};
	my $xval = $value->{'xVal'};
	my $yval = $value->{'yVal'};
	my $beautyXval = $beautyValue->{'xVal'};
	my $beautyYval = $beautyValue->{'yVal'};
	if($key eq 'skin_color') {
	print "\t\t\t10 = { ";
	createRangeB($xval,$yval,$const_SCmarginOfError,$const_SCcoarse);
	print " }\n";
	} elsif(($key eq 'eye_color') || ($key eq 'hair_color') ) {
	print "\t\t\t10 = { ";
	createRangeB($xval,$yval,$const_marginOfError,$const_coarse);
	print " }\n";
	for(@a) {
	print "\t\t\t0 = { ";
	createRangeB($beautyXval,$beautyYval,$const_beautyMarginOfError/$_,$const_beautyCoarse*$_);
	print " traits = { beauty_$_ } }\n";
	}
	} else {
	print "\t\t\t10 = { name = $xval range = { ";
	createRangeA($yval,$const_marginOfError,$const_coarse);
	print " } }\n";
	for(@a) {
	print "\t\t\t0 = { name = $xval range = { ";
	createRangeA($beautyYval,$const_beautyMarginOfError/$_,$const_beautyCoarse*$_);
	print " }  traits = { beauty_$_ } }\n";
	}
	}
	print "\t}\n";
}
print "\n}\n";

close(FH);
