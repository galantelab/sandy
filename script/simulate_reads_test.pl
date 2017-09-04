#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: simulate_reads_test.pl
#
#        USAGE: ./simulate_reads_test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02-09-2017 20:57:34
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use SimulateReads;
my $app = SimulateReads->new;
#my $app = SimulateReads->new(argv => \@ARGV);
$app->run;

