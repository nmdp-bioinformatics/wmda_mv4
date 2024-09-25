#!/usr/bin/env perl
############################################################################
# SCRIPT NAME:	allclean.pl
# DESCRIPTION:	
#
# DATE WRITTEN: 2024-06-25
# WRITTEN BY:   Martin Maiers
#
############################################################################
use strict;    # always
use warnings;  # or else



my %constraint;
#$constraint{D}{miss_dqb1}=1;
$constraint{D}{clean}=1;
$constraint{P}{clean}=1;

my %P;
my $cp = "data/clean_patient.csv";
open FILE, $cp or die "$!: $cp";
my @pheader;
while(<FILE>) {
  chomp;
  my ($id, @data) = split /,/;
  if ($id eq "patient_id") {
    @pheader = @data;
  } else {
    for (my $i=0; $i<=$#pheader; $i++) {
      $P{$id}{$pheader[$i]} = $data[$i];
    }
  }
}

my %D;
my @dheader;
my $cd = "data/clean_donor.csv";
open FILE, $cd or die "$!: $cd";
while(<FILE>) {
  chomp;
  my ($id, @data) = split /,/;
  if ($id eq "donor_id") {
    @dheader = @data;
  } else {
    for (my $i=0; $i<=$#dheader; $i++) {
      $D{$id}{$dheader[$i]} = $data[$i];
    }
  }
}

my $all = "output/all.txt";
my $allclean = "output/all.clean.txt";
open FILE, $all or die "$!: $all";
open OFILE, ">$allclean" or die "$!: $allclean";

while(<FILE>) {
  chomp;
  my ($patient, $donor, @data) = split /,/;
  next if $donor eq "DONOR_ID";
  my $keep_p = 0;
  my $keep_d = 0;
  foreach my $type (keys %constraint) {
    if ($type eq "D") {
      foreach my $c(keys %{$constraint{$type}}) {
        $keep_d=1 if $D{$donor}{$c} == $constraint{$type}{$c};
      }
    } elsif ($type eq "P") {
      foreach my $c(keys %{$constraint{$type}}) {
        $keep_p=1 if $P{$patient}{$c} == $constraint{$type}{$c};
      }
    } else {
      die "type: $type";
    }
  }
  if ($keep_p && $keep_d) {
    print OFILE join (',', $patient, $donor, @data),  "\n";
  }
}

exit 0;

