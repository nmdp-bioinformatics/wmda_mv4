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

my %P;
my $cp = "data/clean_patient.csv";
open FILE, $cp or die "$!: $cp";
while(<FILE>) {
  chomp;
  my ($id) = split /,/;
  $P{$id}++;
}

my %D;
my $cd = "data/clean_donor.csv";
open FILE, $cd or die "$!: $cd";
while(<FILE>) {
  chomp;
  my ($id) = split /,/;
  $D{$id}++;
}

my $all = "output/all.txt";
my $allclean = "output/all.clean.txt";
open FILE, $all or die "$!: $all";
open OFILE, ">$allclean" or die "$!: $allclean";

while(<FILE>) {
  chomp;
  my ($patient, $donor, @data) = split /,/;
  next unless defined $D{$donor}; 
  next unless defined $P{$patient}; 
  print OFILE join (',', $patient, $donor, @data),  "\n";
}

exit 0;

