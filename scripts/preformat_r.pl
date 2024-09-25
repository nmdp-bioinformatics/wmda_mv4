#!/usr/bin/env perl
############################################################################
# SCRIPT NAME:	preformat_r.pl
# DESCRIPTION:	
#
# DATE WRITTEN: 2024-06-25
# WRITTEN BY:   Martin Maiers
#
############################################################################
use strict;    # always
use warnings;  # or else


my $file = "data/MV4/patients.csv";
open FILE, $file or die "$!: $file";

while(<FILE>) {
  chomp;
  my ($patient_id, $a1, $a2, $b1, $b2, $c1, $c2, $drb11, $drb12, $dqb11, $dqb12, $hf_set) = split /,/;
  
  if ($patient_id eq "PATIENT_ID") {
    print join (',', $patient_id, $a1, $a2, $b1, $b2, $c1, $c2, $drb11, $drb12, $dqb11, $dqb12, $hf_set), "\n";
  } else {
    print join (',', $patient_id,
      add_loc("A", $a1), add_loc("A", $a2), 
      add_loc("B", $b1), add_loc("B", $b2), 
      add_loc("C", $c1), add_loc("C", $c2), 
      add_loc("DRB1", $drb11), add_loc("DRB1", $drb12), 
      add_loc("DQB1", $dqb11), add_loc("DQB1", $dqb12), $hf_set);
    print "\n";
  }
}

exit 0;

sub add_loc {
  my ($loc, $typ) = @_;
  return "" if !defined $typ;
  return "" if !length $typ;
  if (length($typ)<=2) {
     $loc = "DQ" if $loc eq "DQB1";
     $loc = "DR" if $loc eq "DRB1";
     return $loc.$typ;
  } else {
    return join '*', $loc, $typ;
  }
}

