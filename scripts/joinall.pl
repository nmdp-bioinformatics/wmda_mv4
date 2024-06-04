#!/usr/bin/env perl
############################################################################
# SCRIPT NAME:	joinall
# DESCRIPTION:	join results from all algorithms and output linked data
#
# DATE WRITTEN: 2024-01-21
# WRITTEN BY:   Martin Maiers
############################################################################
use strict;    
use warnings;  
use Config::JSON;

my $file = "conf/config.json";
my $config = Config::JSON->new($file);

my $mv4_datadir = $config->get("mv4_datadir");
my $keep_zero_prob = $config->get("keep_zero_prob");
my $joinfile = $config->get("joinfile");
my $r= $config->get("results");


open JOINFILE, "> $joinfile" or die "$!: $joinfile";

my %D;
foreach my $key (sort keys %{$r}) {
  my $file = $$r{$key};
  open FILE, $file or die "$!: $file";

  while(<FILE>) {
    chomp;
    my ($p, $d, @data) = split /,/;
    next if $p =~/ID/;
    $D{$p}{$d}{$key} = \@data;
  } 
}


foreach my $p (sort keys %D) {
  foreach my $d (sort keys %{$D{$p}}) {
    # uncomment this to only read 100 donors
    #next if $d gt "D000099";
    my @keys=();
    my @mmval=();
    my @p10val=();
    foreach my $key (sort keys %{$r}) {
      if (defined $D{$p}{$d}{$key}) {
        my $mm = $D{$p}{$d}{$key}[13-1-2];
        my $p8 = $D{$p}{$d}{$key}[14-1-2];
        my $p9 = $D{$p}{$d}{$key}[15-1-2];
        my $p10 = $D{$p}{$d}{$key}[16-1-2];
         
        # skip cases where probabilities sum to zero
        if (!$keep_zero_prob) {
          next unless 
              defined $p8 && defined $p9 && defined $p10 &&
              $p8=~/\d/ &&
              $p9=~/\d/ &&
              $p10=~/\d/ &&
              $p8>=0 && $p9>=0 && $p10>=0 && 
              $p8 + $p9 + $p10 > 0;
        }

        push @keys, $key;
        push @mmval, $mm;
        push @p10val, $p10;
      }
    }
    next unless @keys;
    #PATIENT_ID,DONOR_ID,A1,A2,B1,B2,C1,C2,DRB11,DRB12,DQB11,DQB12,Count_MM,P8_10,P9_10,P10_10,HF_SET_PATIENT,EXPLAINED_PATIENT,HF_SET_DONOR,EXPLAINED_DONOR
    print JOINFILE join (',', $p, $d, join('', @keys), @mmval, @p10val), "\n";
  }
}
exit 0;

