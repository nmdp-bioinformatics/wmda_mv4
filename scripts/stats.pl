#!/usr/bin/env perl
############################################################################
# SCRIPT NAME:	stats.pl
# DESCRIPTION:	compute stats on output
#
# DATE WRITTEN: 2024-05-30
# WRITTEN BY:   Martin Maiers
#
############################################################################
use strict;    
use warnings;  
use Config::json;

my $file = "conf/config.json";
my $config = Config::JSON->new($file);

my $joinfile = $config->get("joinfile");
my $statsfile = $config->get("statsfile");

#open JOINFILE, "$joinfile" or die "$!: $joinfile";
#open STATSFILE, "> $statsfile" or die "$!: $statsfile";

`echo "# pairs output by the same algorithm" >$statsfile`;
`cut -f 3 -d, $joinfile | sort |uniq -c |sort -rn >>$statsfile`;


`echo "# pairs output by 5, what is the range of Count_MM values">>$statsfile`;
`cut -f 3-8 -d, $joinfile|grep ACDNZ | sort |uniq -c |sort -rn >>$statsfile`;

`echo "# pairs output by 4, what is the range of Count_MM values">>$statsfile`;
`cut -f 3-7 -d, $joinfile|grep ADNZ | sort |uniq -c |sort -rn >>$statsfile`;

`echo "# pairs output by 5, what is the range of Count_MM and P10/10 values">>$statsfile`;
`cut -f 3-99 -d, $joinfile|grep ACDNZ | sort |uniq -c |sort -rn >>$statsfile`;

`echo "# pairs output by 5 with 0 Count_MM what is the range of  P10/10 values">>$statsfile`;
`cut -f 3-99 -d, $joinfile|grep ACDNZ,0,0,0,0,0 | sort |uniq -c |sort -rn >>$statsfile`;

`echo "# pairs output by 5 with 1 Count_MM what is the range of  P10/10 values">>$statsfile`;
`cut -f 3-99 -d, $joinfile|grep ACDNZ,1,1,1,1,1 | sort |uniq -c |sort -rn >>$statsfile`;

`echo "# pairs output by 5 with 2 Count_MM what is the range of  P10/10 values">>$statsfile`;
`cut -f 3-99 -d, $joinfile|grep ACDNZ,2,2,2,2,2 | sort |uniq -c |sort -rn >>$statsfile`;

exit 0;

