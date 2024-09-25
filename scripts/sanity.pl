#!/usr/bin/env perl
############################################################################
# SCRIPT NAME:	sanity check
# DESCRIPTION:	perform sanity check
#
# DATE WRITTEN: 2024-09-11 Never forget
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
my $errfile = $config->get("errfile");
my $r= $config->get("results");
my $patientfile = $config->get("patientfile");
my $donorfile = $config->get("donorfile");


# patientfile
my %P; 
# patients
open FILE, $patientfile or die "$!: $patientfile";
while(<FILE>) {
  chomp;
  my ($patient, $a1, $a2, $b1, $b2, $c1, $c2, $drb1_1, $drb1_2, $dqb1_1, $dqb1_2, $hfset) = split /,/;

  $P{$patient}{A}= istyped($a1, $a2);
  $P{$patient}{B}= istyped($b1, $b2);
  $P{$patient}{C}= istyped($c1, $c2);
  $P{$patient}{DRB1}= istyped($drb1_1, $drb1_2);
  $P{$patient}{DQB1}= istyped($dqb1_1, $dqb1_2);
}

# donorfile
my %D; 
# donors
open FILE, $donorfile or die "$!: $donorfile";
while(<FILE>) {
  chomp;
  my ($donor, $a1, $a2, $b1, $b2, $c1, $c2, $drb1_1, $drb1_2, $dqb1_1, $dqb1_2, $donor_type, $hfset) = split /,/;

  $D{$donor}{A}= istyped($a1, $a2);
  $D{$donor}{B}= istyped($b1, $b2);
  $D{$donor}{C}= istyped($c1, $c2);
  $D{$donor}{DRB1}= istyped($drb1_1, $drb1_2);
  $D{$donor}{DQB1}= istyped($dqb1_1, $dqb1_2);
}


my @loci = qw/A B C DRB1 DQB1/;
my @allkeys = sort keys %{$r};
foreach my $key (@allkeys) {
  my $file = $$r{$key};
  open FILE,  $file or die "$!: $file";
  open ERRFILE,  ">$errfile.$key" or die "$!: $errfile.$key";

  while(<FILE>) {
    chomp;
    my ($p, $d, @data) = split /,/;
    my ($a1,$a2,$b1,$b2,$c1,$c2,$drb11,$drb12,$dqb11,$dqb12,$count_mm,$p8_10,$p9_10,$p10_10,$hfset_patient,$explained_patient, $hfset_donor,$explained_donor) = @data;
    next if $hfset_patient eq "HFSET_PATIENT";
    next if $hfset_patient eq "HF_SET_PATIENT"; # for D
    next if $hfset_patient eq "EXPLAINED_PATIENT"; # for Z

    # check mgs
    my (@mg) = ($a1,$a2,$b1,$b2,$c1,$c2,$drb11,$drb12,$dqb11,$dqb12);
    for (my $i=0; $i<= $#loci; $i++) {
      my $loc = $loci[$i];      
      for (my $j=1; $j<= 2; $j++) {
        my $mg_field = $loc.$j;
        my $mg_index = ($i * 2) + $j -1;
        if ($mg[$mg_index]=~/[APLMQR]/ or $mg[$mg_index]=~/[APLMQR]\*/ or
           ($mg[$mg_index] eq "" && (!$P{$p}{$loc} or !$D{$d}{$loc}))) { 
          #pass
        } else {
          warn "key: $key invalid mg: $mg_field for $p $d: $mg[$i]\n";
          my $errstring = sprintf "INVALID_MG_%s %s", $mg_field, $mg[$mg_index];
          print ERRFILE join (':', $errstring, join (',',$p, $d, @data)),  "\n";
        }
      }
    }

    # check count_mm

    if ($count_mm=~/^[012]$/) {
      #pass
    } else {
      warn "key: $key invalid count_mm\n";
      my $errstring = sprintf "INVALID_COUNT_MM %s", $count_mm;
      print ERRFILE join (':', $errstring, join (',',$p, $d, @data)),  "\n";
    }

    # check probs
    my (@probs) = ($p8_10, $p9_10, $p10_10);
    my @prob_fields = qw/p8_10 p9_10 p10_10/;
    for (my $i=0; $i<= $#prob_fields; $i++) {
      if (($probs[$i] eq "") or ($probs[$i]=~/\d/ && $probs[$i] eq int $probs[$i] && $probs[$i]>=0 && $probs[$i] <=100)) {
        #pass
      } else {
        warn "key: $key invalid prob: $probs[$i] for $p $d: $prob_fields[$i]\n";
        my $errstring = sprintf "INVALID_PROB_%s %s",$prob_fields[$i], $probs[$i];
        print ERRFILE join (':', $errstring, join (',',$p, $d, @data)),  "\n";
      }
    }
    if (!$hfset_patient) {
      warn "key: $key hfset_patient missing for $p\n";
      my $errstring = "HFSET_PATIENT_MISSING";
      print ERRFILE join (':', $errstring, join (',',$p, $d, @data)),  "\n";
    }
    if (!$hfset_donor) {
      warn "key: $key hfset_donor missing for $p\n";
      my $errstring = "HFSET_DONOR_MISSING";
      print ERRFILE join (':', $errstring, join (',',$p, $d, @data)),  "\n";
    }
  
  } 
}
exit 0;


sub istyped {
  my ($t1, $t2) = @_;
  return 1 if defined $t1 && $t1;
  return 1 if defined $t2 && $t2;
  return 0;
}
