#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: insertdb.pl
#
#        USAGE: ./insertdb.pl  
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
#      CREATED: 19-08-2017 01:37:14
#     REVISION: ---
#===============================================================================

use My::Base;
use Path::Class 'file';
use Getopt::Long;
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;
use Data::Dumper;

use Quality::Handle;
my $db = Quality::Handle->new;

my $progname = file(__FILE__)->basename;

my ($sequencing_system, $size, $source);
my $type = 'raw';
my $help = 0;
$LOG_VERBOSE = 0;

unless (@ARGV) {
	print_report($db->make_report);
	exit 0;
}
	
GetOptions (
	'help|h'                => \$help,
	'verbose|v'             => \$LOG_VERBOSE,
	'sequencing-system|q=s' => \$sequencing_system,
	'size|s=i'              => \$size,
	'source|f=s'            => \$source,
    'type|t=s'              => \$type
) or die "Error in command line arguments";

usage() && exit 0 if $help;

my $matrix_file = shift
	or die "<MATRIX> not defined\n" => usage();

unless (-f $matrix_file)    { die "'$matrix_file' is not a file\n"    => usage() }
unless ($sequencing_system) { die "sequencing-system not defined\n"   => usage() }
unless ($source)            { die "source not defined\n"              => usage() }
unless ($size)              { die "size not defined\n"                => usage() }
unless ($size > 0)          { die "size must be a positive integer\n" => usage() }

$db->insertdb($matrix_file, $sequencing_system, $size, $source, $type);
#$db->deletedb($sequencing_system, $size);
#my $q = $db->retrievedb($sequencing_system, $size);
#print Dumper($q);

sub usage {
	say STDERR "usage $progname <MATRIX> -q [sequencing system] -s [size] -f [source]";
}

sub print_report {
	my $report_ref = shift;
	return if not defined $report_ref;

	my $format = "\t%*s\t%*s\t%*s\n";
	my ($s1, $s2, $s3) = map {length} qw/sequencing_system/x3;
	printf $format => $s1, "sequencing system", $s2, "size", $s3, "source";

	for my $sequencing_system (sort keys %$report_ref) {
		my $attr = $report_ref->{$sequencing_system};
		for my $entry (sort { $a->{size} <=> $b->{size} } @$attr) {
			printf $format => $s1, $sequencing_system, $s2, $entry->{size}, $s3, $entry->{source};
		}
	}
}
