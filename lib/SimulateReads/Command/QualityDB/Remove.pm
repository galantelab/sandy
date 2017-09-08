#
#===============================================================================
#
#         FILE: Remove.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07-09-2017 22:48:09
#     REVISION: ---
#===============================================================================

package SimulateReads::Command::QualityDB::Remove;

use My::Base 'class';

extends 'SimulateReads::Command::QualityDB';

sub opt_spec {
	'help|h',
	'man|M',
	'verbose|v',
	'quality-profile|q=s',
	'read-size|r=i'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	
	if (not exists $opts->{'quality-profile'}) {
		die "Option 'quality-profile' not defined\n";
	}

	if (not exists $opts->{'read-size'}) {
		die "Option 'read-size' not defined\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;
	$self->deletedb($opts->{'quality-profile'}, $opts->{'read-size'});
}

__END__

=head1 NAME

simulate_reads - Creates single-end and paired-end fastq reads for transcriptome and genome simulation 

=head1 SYNOPSIS

 simulate_reads qualitydb remove -q <entry name> -r <size>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages
  -q, --quality-profile    quality-profile name for the database [required]
  -r, --read-size          the read-size of the quality-profile [required, Integer]

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago Miller - L<tmiller@mochsl.org.br>

=cut
