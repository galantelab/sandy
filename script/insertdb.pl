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
use My::Schema;
use Path::Class 'file';
use Getopt::Long;
use Storable qw/nfreeze thaw/;
use Data::Dumper;

my $progname = file(__FILE__)->basename;
my $db_fn = file(__FILE__)->dir->parent->file('share', 'quality_profile.db');

my ($sequencing_system, $size, $source);
my $help = 0;
$LOG_VERBOSE = 0;

unless (@ARGV) {
	report();
	exit 0;
}
	
GetOptions (
	'help|h'                => \$help,
	'verbose|v'             => \$LOG_VERBOSE,
	'sequencing-system|q=s' => \$sequencing_system,
	'size|s=i'              => \$size,
	'source|f=s'            => \$source
) or die "Error in command line arguments";

usage() && exit 0 if $help;

my $matrix_file = shift
	or die "<MATRIX> not defined\n" => usage();

unless (-f $matrix_file)    { die "'$matrix_file' is not a file\n"    => usage() }
unless ($sequencing_system) { die "sequencing-system not defined\n"   => usage() }
unless ($source)            { die "source not defined\n"              => usage() }
unless ($size)              { die "size not defined\n"                => usage() }
unless ($size > 0)          { die "size must be a positive integer\n" => usage() }

log_msg ":: Connecting to database $db_fn";
my $schema = My::Schema->connect("dbi:SQLite:$db_fn", "", "", { RaiseError => 1, PrintError => 0 });

log_msg ":: Checking if there is already a sequencing-system '$sequencing_system' ...";
my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
if ($seq_sys_rs) {
	log_msg ":: Found '$sequencing_system'";
	log_msg ":: Searching for a quality entry '$sequencing_system:$size' ...";
	my $quality_rs = $schema->resultset('Quality')->search(
		{
			name    => $sequencing_system,
			size    => $size 
		},
		{  prefetch => ['sequencing_system'] }
	);
	if ($quality_rs) {
		die "There is already a quality entry for $sequencing_system:$size";
	}
	log_msg ":: Not found '$sequencing_system:$size'";
} else {
	log_msg ":: sequencing-system '$sequencing_system' not found";
}

log_msg ":: Indexing '$matrix_file' ...";
my $arr = index_quality($matrix_file, $size);
log_msg ":: Converting array to bytes ...";
my $bytes = freeze $arr;

unless ($seq_sys_rs) {
	log_msg ":: Creating sequencing-system entry for '$sequencing_system' ...";
	$seq_sys_rs = $schema->resultset('SequencingSystem')->create({ name => $sequencing_system });
}

log_msg ":: Storing quality matrix entry ...";
my $quality_rs = $seq_sys_rs->create_related( qualities => {
	source => $source,
	size   => $size,
	matrix => $bytes
});

log_msg ":: FINITO!";

sub usage {
	say STDERR "usage $progname <MATRIX> -q [sequencing system] -s [size] -f [source]";
}

sub index_quality {
	my ($file, $size) = @_;
	open my $fh, "<" => $file
		or die "Cannot open '$file'";
	my @arr;
	my $line = 0;
	while (<$fh>) {
		$line++;
		chomp;
		my @tmp = split //;
		die "Error parsing '$file': Line $line do not have length $size" if scalar @tmp != $size;
		for (my $i = 0; $i < $size; $i++) {
			push @{ $arr[$i] } => $tmp[$i];
		}
	}
	close $fh;
	return \@arr;
}

sub report {
	my $schema = My::Schema->connect("dbi:SQLite:$db_fn", "", "", { RaiseError => 1, PrintError => 0 });
	my $quality_rs = $schema->resultset('Quality')->search(
		{},
		{
			order_by => [{ -asc => 'sequencing_system.name' }, { -asc => 'size'}],
			prefetch => ['sequencing_system']
		}
	);

	my $format = "\t%*s\t%*s\t%*s\n";
	my ($s1, $s2, $s3) = map {length} qw/sequencing_system/x3;
	printf $format => $s1, "sequencing system", $s2, "size", $s3, "source"
		if $quality_rs;

	while (my $quality = $quality_rs->next) {
		my $sequencing_system = $quality->sequencing_system->name;
		my $size = $quality->size;
		my $source = $quality->source;
		printf $format => $s1, $sequencing_system, $s2, $size, $s3, $source;
	}
}
