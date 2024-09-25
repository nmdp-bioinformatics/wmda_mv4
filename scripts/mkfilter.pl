#!/usr/bin/env perl
#########################################################################
# SCRIPT NAME:	mkfilter
# DESCRIPTION:	create files of ID,filters
#
# DATE WRITTEN: 2024-06-25
# WRITTEN BY:   Martin Maiers
#
#########################################################################
use strict;    # always
use warnings;  # or else



my $v = 1; # verbose

my @fields = qw/clean highres sero lowres mac highres_null mac_null indepedent_null xx_null homo_a homo_b homo_c homo_drb1 homo_dqb1/;


my %D;
my %P;


# highres
print STDERR "highres...\n" if $v;
my $patient_redux = "cut -f 1,23 -d, data/patients.redux.csv";
my $donor_redux = "cut -f 1,22,24 -d, data/donors.redux.csv";
open FILE, "$donor_redux |" or die "$!: $donor_redux";
while (<FILE>) {
  my ($id, $donor_type, $gl) = split /,/;
  next unless $donor_type eq "D";
  $D{$id}{highres} = index($gl, '/') eq -1 ? 1 : 0;
}

open FILE, "$patient_redux |" or die "$!: $patient_redux";
while (<FILE>) {
  my ($id, $gl) = split /,/;
  $P{$id}{highres} = index($gl, '/') eq -1 ? 1 : 0;
}


print STDERR "classification...\n" if $v;
my $file = "data/classification/donor_classifications.csv";
open FILE, $file or die "$!: $file";
while(<FILE>) {
  chomp;
  my ($id, $sero, $lowres, $missing, $mac, $null, $hires) = split /,/;
  next if $id eq "ID";
  $D{$id}{sero} = $sero eq "Y" ? 1 : 0;
  $D{$id}{lowres} = $lowres eq "Y" ? 1 : 0;
  $D{$id}{mac} = $mac eq "Y" ? 1 : 0;
  $D{$id}{hires} = $hires eq "Y" ? 1 : 0;
  $D{$id}{classification}=1 if 
    $hires eq "Y" &&
    $sero ne "Y" &&
    $lowres ne "Y" &&
    $missing ne "Y" &&
    $mac ne "Y" &&
    $null ne "Y";
}
$file = "data/classification/patient_classifications.csv";
open FILE, $file or die "$!: $file";
while(<FILE>) {
  chomp;
  my ($id, $sero, $lowres, $missing, $mac, $null, $hires) = split /,/;
  next if $id eq "ID";
  $P{$id}{sero} = $sero eq "Y" ? 1 : 0;
  $P{$id}{lowres} = $lowres eq "Y" ? 1 : 0;
  $P{$id}{mac} = $mac eq "Y" ? 1 : 0;
  $P{$id}{hires} = $hires eq "Y" ? 1 : 0;
  $P{$id}{classification}=1 if 
    $hires eq "Y" &&
    $sero ne "Y" &&
    $lowres ne "Y" &&
    $missing ne "Y" &&
    $mac ne "Y" &&
    $null ne "Y";
}
  


# hom
print STDERR "homozygosity...\n" if $v;
$file = "data/homo/mv4_potential_homo_donor_detail.csv";
open FILE, $file or die "$!: $file";

while(<FILE>) {
  chomp;
  s/"//g;
  my ($id, $flag) = split /,/;
  $D{$id}{homo}++ if $flag eq "N";
  $D{$id}{homo_A}++ if $flag eq "A";
  $D{$id}{homo_B}++ if $flag eq "B";
  $D{$id}{homo_C}++ if $flag eq "C";
  $D{$id}{homo_DRB1}++ if $flag eq "DRB1";
  $D{$id}{homo_DQB1}++ if $flag eq "DQB1";
}

$file = "data/homo/mv4_potential_homo_patients.csv";
open FILE, $file or die "$!: $file";

while(<FILE>) {
  chomp;
  s/"//g;
  my ($id, $flag) = split /,/;;
  $P{$id}{homo}++ if $flag eq "N";
  $P{$id}{homo_A}++ if $flag eq "A";
  $P{$id}{homo_B}++ if $flag eq "B";
  $P{$id}{homo_C}++ if $flag eq "C";
  $P{$id}{homo_DRB1}++ if $flag eq "DRB1";
  $P{$id}{homo_DQB1}++ if $flag eq "DQB1";
}



#null
print STDERR "null...\n" if $v;
$file = "data/null/Donor_null_allele_flags.csv";
open FILE, $file or die "$!: $file";

while(<FILE>) {
  chomp;
  # HIGHRES_NULL_ALLELE,MAC_NULL_ALLELE,INDEPENDENT_NULL,XX_NULL_ALLELE

  my ($id, $f1, $f2, $f3, $f4) = split /,/;
  next if $id =~/ID/;
  $D{$id}{null}++ if $f1+$f2+$f3+$f4 ==0;
  $D{$id}{highres_null} = $f1;
  $D{$id}{mac_null} = $f2;
  $D{$id}{independent_null} = $f3;
  $D{$id}{xx_null} = $f4;
} 
$file = "data/null/Patient_null_allele_flags.csv";
open FILE, $file or die "$!: $file";

while(<FILE>) {
  chomp;
  my ($id, $f1, $f2, $f3, $f4) = split /,/;;
  next if $id =~/ID/;
  $P{$id}{null}++ if $f1+$f2+$f3+$f4 ==0;
  $P{$id}{highres_null} = $f1;
  $P{$id}{mac_null} = $f2;
  $P{$id}{independent_null} = $f3;
  $P{$id}{xx_null} = $f4;
}


print STDERR "writing...\n" if $v;
my $clean_donor = "data/clean_donor.csv";
open CD, ">$clean_donor" or die "$!: $clean_donor";
my $clean_patient = "data/clean_patient.csv";
open CP, ">$clean_patient" or die "$!: $clean_patient";


print CD join (',', "donor_id", @fields), "\n";
print CP join (',', "patient_id", @fields, "\n");
foreach my $id (keys %P) {
  my @out = ();
  $P{$id}{clean}= 
      defined $P{$id}{classification} &&  
      defined $P{$id}{homo} &&  
      defined $P{$id}{null} ? 1 : 0;
  foreach my $field (@fields) {
    push @out, defined $P{$id}{$field} ?  $P{$id}{$field} : 0;
  }
  print CP join (',', $id, @out), "\n";
}


foreach my $id (keys %D) {
  my @out = ();
  $D{$id}{clean}= 
      defined $D{$id}{classification} &&  
      defined $D{$id}{homo} &&  
      defined $D{$id}{null} ? 1 : 0;
  foreach my $field (@fields) {
    push @out, defined $D{$id}{$field} ?  $D{$id}{$field} : 0;
  }
  print CD join (',', $id, @out), "\n";
}



exit 0;

sub ishighres {
  my $gl = shift;
  return 1 if index($gl, '/') eq -1;
  return 0;
}

