#!/usr/bin/env perl
############################################################################
# SCRIPT NAME:	hwsample
# DESCRIPTION:	sample for homework
#
# DATE WRITTEN: 2024-03-29
# WRITTEN BY:   Martin Maiers
############################################################################
use strict;    # always
use warnings;  # or else
use Config::JSON;

my $file = "conf/config.json";
my $config = Config::JSON->new($file);

my $mv4_datadir = $config->get("mv4_datadir");
my $r= $config->get("results");
my $keep_zero_prob = $config->get("keep_zero_prob");
my $joinfile = $config->get("joinfile");
my $statsfile =$config->get("statsfile");

# HW
my $numsamples =$config->get("homeworknum");
my $homeworkdir =$config->get("homeworkdir");
my $skipcord =$config->get("skipcord");

# patients donors
my $patientfile =$config->get("patientfile");
my $donorfile =$config->get("donorfile");

my %P;
# patients
open FILE, $patientfile or die "$!: $patientfile";
while(<FILE>) {
  chomp;
  my ($patient, $a1, $a2, $b1, $b2, $c1, $c2, $drb1_1, $drb1_2, $dqb1_1, $dqb1_2, $hfset) = split /,/;
  $P{$patient}= ishighres($a1, $a2, $b1, $b2, $c1, $c2, $drb1_1, $drb1_2, $dqb1_1, $dqb1_2);
   
}

my %D;
# donors
open FILE, $donorfile or die "$!: $donorfile";
while(<FILE>) {
  chomp;
  my ($donor, $a1, $a2, $b1, $b2, $c1, $c2, $drb1_1, $drb1_2, $dqb1_1, $dqb1_2, $donor_type, $hfset) = split /,/;

  if ($skipcord) {
    next unless $donor_type eq "D";
  }
  $D{$donor}= ishighres($a1, $a2, $b1, $b2, $c1, $c2, $drb1_1, $drb1_2, $dqb1_1, $dqb1_2);
}


open FILE, $joinfile or die "$!: $joinfile";
my %A;
while(<FILE>) {
  chomp;
  my($patient, $donor, $alg) = split /,/;
  $A{$alg}{$patient}{$donor}++;
}


foreach my $alg (keys %A) {
  my $hwcount=0;
  mkdir $homeworkdir unless -e $homeworkdir;
  my $outfile = "$homeworkdir/$alg.csv";
  open OUTFILE, ">$outfile" or die "$!: $outfile";

  my %HWconfig;
  my %HW; 

  # start with the most constraints
  $HWconfig{onepatient}=1;
  $HWconfig{onedonor}=1;
  $HWconfig{highrespatient}=1;
  $HWconfig{highresdonor}=1;
  selectHW(\%{$A{$alg}}, \%HWconfig, \%HW, $numsamples);


  # remove constraints one by one
  $HWconfig{onepatient}=0;
  selectHW(\%{$A{$alg}}, \%HWconfig, \%HW, $numsamples);

  $HWconfig{onedonor}=0;
  selectHW(\%{$A{$alg}}, \%HWconfig, \%HW, $numsamples);

  $HWconfig{highrespatient}=0;
  selectHW(\%{$A{$alg}}, \%HWconfig, \%HW, $numsamples);
  
  $HWconfig{highresdonor}=0;
  selectHW(\%{$A{$alg}}, \%HWconfig, \%HW, $numsamples);


  foreach my $pd(keys %HW) {
    my($p, $d) = split /:/, $pd;
    print OUTFILE join (',', $p,$d), "\n";
  }
}
exit 0;

sub selectHW {
  # pairs, config, hw, numsamples
  my ($aa, $c, $h, $numsamples) = @_;

  # done
  return if scalar keys %{$h} >= $numsamples;

  foreach my $patient (keys %{$aa}) {  
    # if only highres donors
    next if $$c{highrespatient} && !hrpat($patient);

    # if onepatient
    next if $$c{onepatient} && defined $$h{$patient};

    foreach my $donor (keys %{$$aa{$patient}}) {  
      # skip cords perhaps
      next unless isDonor($donor);
      # if only highres donors
      next if $$c{highresdonor} and !hrdon($donor);

      # if onedonor
      foreach my $pd (keys %{$h}) {
        my ($p, $d) = split /:/, $pd;
        next if $donor eq $d;
      }
      if ((scalar keys %{$h}) < $numsamples) {
        my $pd = join (':', $patient, $donor);
        $$h{$pd}++;
      }
    }
  }
}

sub isDonor {
  my $d = shift;
  return defined $D{$d};
}
sub hrdon {
  my $id = shift;
  return $D{$id};
}

sub hrpat {
  my $id = shift;
  return $P{$id};
}

sub ishighres {
  my @hla = @_;
  my $ret =1;
  foreach  my $h (@hla) {
    $ret = 0 unless ishr($h);
  }
  return $ret;
}

sub ishr {
  my $s = shift;
  return 0 unless defined $s;
  return 0 unless length  $s;
  return 1 if $s=~/(\d+):(\d+)/;
  return 0;
}
